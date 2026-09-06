// level-backdrop — bring every portrait's studio backdrop to one colour.
//
//   swift level-backdrop.swift <input> <output.png> [--measure-only]
//
// The photos come from different shoots, so the backdrop ranged from #AEA794
// (Annie) to #D7D3CA (Rachel) and some cards read visibly darker than others.
//
// The mask is built by FLOOD FILL from the border, not by colour distance.
// That matters: Rachel's cheek is only 30 apart from her backdrop on the
// widest channel, so a pure colour threshold pulled her skin 9-15 levels with
// the background. Flood fill is topological — skin is enclosed by hair and
// clothing that are nowhere near the backdrop colour, so the fill can never
// reach a face no matter how similar the colour happens to be.
//
// The mask is then blurred a few pixels and used as a weight on a single
// uniform shift (target - thisBackdrop). A pure backdrop pixel lands exactly
// on the target; a half-hair/half-backdrop pixel gets half the shift, which is
// what it should get; the subject is untouched. There is no hard mask edge to
// halo.

import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let TARGET = (r: 201.0, g: 195.0, b: 179.0)   // #C9C3B3 — the house backdrop
let FILL_TOL = 22.0                            // max-channel distance still counted as backdrop
let FEATHER  = 3                               // box-blur radius applied to the mask, in px

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("usage: level-backdrop <input> <output.png> [--measure-only]\n".data(using: .utf8)!)
    exit(2)
}
let inPath = args[1]
let measureOnly = args.contains("--measure-only")
let outPath = (args.count > 2 && !args[2].hasPrefix("--")) ? args[2] : ""

guard let srcRef = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(srcRef, 0, nil) else { exit(1) }
let w = img.width, h = img.height
let cs = CGColorSpaceCreateDeviceRGB()
let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: w*h*4)
defer { buf.deallocate() }
buf.initialize(repeating: 0, count: w*h*4)
CGContext(data: buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4,
          space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)!
    .draw(img, in: CGRect(x: 0, y: 0, width: w, height: h))

var sr: [Int] = [], sg: [Int] = [], sb: [Int] = []
for (cx, cy) in [(8, 8), (w-9, 8), (8, h-9), (w-9, h-9)] {
    for dx in -6...5 { for dy in -6...5 {
        let i = ((cy+dy)*w + (cx+dx))*4
        sr.append(Int(buf[i])); sg.append(Int(buf[i+1])); sb.append(Int(buf[i+2]))
    } }
}
sr.sort(); sg.sort(); sb.sort()
let src = (r: Double(sr[sr.count/2]), g: Double(sg[sg.count/2]), b: Double(sb[sb.count/2]))
let d = (r: TARGET.r - src.r, g: TARGET.g - src.g, b: TARGET.b - src.b)

if measureOnly {
    print(String(format: "%@\tbg=#%02X%02X%02X\tshift=(%+.0f,%+.0f,%+.0f)",
                 (inPath as NSString).lastPathComponent, Int(src.r), Int(src.g), Int(src.b), d.r, d.g, d.b))
    exit(0)
}
guard !outPath.isEmpty else { exit(2) }

// ---- flood fill the backdrop inward from every border pixel ---------------
@inline(__always) func isBackdrop(_ p: Int) -> Bool {
    let i = p*4
    let dr = abs(Double(buf[i]) - src.r), dg = abs(Double(buf[i+1]) - src.g), db = abs(Double(buf[i+2]) - src.b)
    return max(dr, max(dg, db)) <= FILL_TOL
}
var mask = [Float](repeating: 0, count: w*h)
var seen = [Bool](repeating: false, count: w*h)
var stack: [Int] = []
for x in 0..<w { for y in [0, h-1] { let p = y*w + x; if !seen[p] && isBackdrop(p) { seen[p] = true; stack.append(p) } } }
for y in 0..<h { for x in [0, w-1] { let p = y*w + x; if !seen[p] && isBackdrop(p) { seen[p] = true; stack.append(p) } } }
while let p = stack.popLast() {
    mask[p] = 1
    let x = p % w, y = p / w
    if x > 0     { let q = p-1; if !seen[q] && isBackdrop(q) { seen[q] = true; stack.append(q) } }
    if x < w-1   { let q = p+1; if !seen[q] && isBackdrop(q) { seen[q] = true; stack.append(q) } }
    if y > 0     { let q = p-w; if !seen[q] && isBackdrop(q) { seen[q] = true; stack.append(q) } }
    if y < h-1   { let q = p+w; if !seen[q] && isBackdrop(q) { seen[q] = true; stack.append(q) } }
}

// ---- feather the mask (separable box blur, twice) -------------------------
func blur(_ m: inout [Float], _ r: Int) {
    var tmp = [Float](repeating: 0, count: w*h)
    for y in 0..<h {
        var acc: Float = 0
        for x in -r...r { acc += m[y*w + min(max(x, 0), w-1)] }
        for x in 0..<w {
            tmp[y*w + x] = acc / Float(2*r + 1)
            acc -= m[y*w + min(max(x - r, 0), w-1)]
            acc += m[y*w + min(max(x + r + 1, 0), w-1)]
        }
    }
    for x in 0..<w {
        var acc: Float = 0
        for y in -r...r { acc += tmp[min(max(y, 0), h-1)*w + x] }
        for y in 0..<h {
            m[y*w + x] = acc / Float(2*r + 1)
            acc -= tmp[min(max(y - r, 0), h-1)*w + x]
            acc += tmp[min(max(y + r + 1, 0), h-1)*w + x]
        }
    }
}
blur(&mask, FEATHER); blur(&mask, FEATHER)

// ---- apply -----------------------------------------------------------------
@inline(__always) func clamp(_ v: Double) -> UInt8 { UInt8(max(0, min(255, v.rounded()))) }
for p in 0..<(w*h) {
    let wt = Double(mask[p])
    if wt <= 0.001 { continue }
    let i = p*4
    buf[i]   = clamp(Double(buf[i])   + d.r * wt)
    buf[i+1] = clamp(Double(buf[i+1]) + d.g * wt)
    buf[i+2] = clamp(Double(buf[i+2]) + d.b * wt)
}

guard let ctx = CGContext(data: buf, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w*4,
                          space: cs, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue),
      let out = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL,
                                                 UTType.png.identifier as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(dest, out, nil)
guard CGImageDestinationFinalize(dest) else { exit(1) }
let covered = mask.reduce(0) { $0 + ($1 > 0.5 ? 1 : 0) }
print(String(format: "%@  bg #%02X%02X%02X -> #%02X%02X%02X  mask=%.1f%%",
             (outPath as NSString).lastPathComponent,
             Int(src.r), Int(src.g), Int(src.b), Int(TARGET.r), Int(TARGET.g), Int(TARGET.b),
             100.0 * Double(covered) / Double(w*h)))
