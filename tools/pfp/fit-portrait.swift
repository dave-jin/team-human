// fit-portrait — put a team portrait into the Team Human PFP frame.
//
//   swift fit-portrait.swift <input> <output.png> [--measure-only]
//
// Detects the face with Vision, then scales and positions the photo so every
// portrait on the team page shares one face size and one eye line. Margins
// created by scaling down are filled by stretching the source's own edge
// pixels, which is seamless because the studio backdrop is flat and the torso
// leaves the bottom edge vertically.
//
// House frame (see CLAUDE.md -> Current Team):
//   canvas 1584x672 · face width 185px · eye line y=245 · face centred at x=792

import Foundation
import Vision
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

let OUT_W = 1584.0, OUT_H = 672.0
let TARGET_FACE_W = 185.0, TARGET_EYE_Y = 245.0, TARGET_FACE_CX = 792.0

let args = CommandLine.arguments
guard args.count >= 2 else {
    FileHandle.standardError.write("usage: fit-portrait <input> <output.png> [--measure-only]\n".data(using: .utf8)!)
    exit(2)
}
let inPath = args[1]
let measureOnly = args.contains("--measure-only")
let outPath = (args.count > 2 && !args[2].hasPrefix("--")) ? args[2] : ""

guard let src = CGImageSourceCreateWithURL(URL(fileURLWithPath: inPath) as CFURL, nil),
      let img = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
    FileHandle.standardError.write("cannot read \(inPath)\n".data(using: .utf8)!); exit(1)
}
let SW = Double(img.width), SH = Double(img.height)

// ---- face + eye line ------------------------------------------------------
let req = VNDetectFaceLandmarksRequest()
try VNImageRequestHandler(cgImage: img, options: [:]).perform([req])
guard let faces = req.results, !faces.isEmpty,
      let f = faces.max(by: { $0.boundingBox.width < $1.boundingBox.width }) else {
    FileHandle.standardError.write("no face found in \(inPath)\n".data(using: .utf8)!); exit(1)
}
let bb = f.boundingBox
let faceW  = bb.width * SW
let faceCX = (bb.minX + bb.width/2) * SW
var eyeY = (1 - (bb.minY + bb.height * 0.62)) * SH   // fallback if landmarks are missing
if let lm = f.landmarks, let le = lm.leftEye, let re = lm.rightEye {
    func centreY(_ r: VNFaceLandmarkRegion2D) -> Double {
        var sy = 0.0
        for p in r.normalizedPoints { sy += Double(p.y) }
        let gy = bb.minY + CGFloat(sy / Double(r.pointCount)) * bb.height
        return Double((1 - gy) * SH)
    }
    eyeY = (centreY(le) + centreY(re)) / 2
}

// ---- backdrop colour: median of the four corner patches -------------------
let cs = CGColorSpaceCreateDeviceRGB()
let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: img.width * img.height * 4)
defer { buf.deallocate() }
buf.initialize(repeating: 0, count: img.width * img.height * 4)
CGContext(data: buf, width: img.width, height: img.height, bitsPerComponent: 8,
          bytesPerRow: img.width * 4, space: cs,
          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    .draw(img, in: CGRect(x: 0, y: 0, width: SW, height: SH))
var sr: [Int] = [], sg: [Int] = [], sb: [Int] = []
for (cx, cy) in [(8, 8), (img.width - 9, 8), (8, img.height - 9), (img.width - 9, img.height - 9)] {
    for dx in -6...5 { for dy in -6...5 {
        let i = ((cy + dy) * img.width + (cx + dx)) * 4
        sr.append(Int(buf[i])); sg.append(Int(buf[i+1])); sb.append(Int(buf[i+2]))
    } }
}
sr.sort(); sg.sort(); sb.sort()
let bgR = sr[sr.count/2], bgG = sg[sg.count/2], bgB = sb[sb.count/2]

let scale = TARGET_FACE_W / faceW
if measureOnly {
    print(String(format: "%@\tfaceW=%.1f\tfaceCX=%.1f\teyeY=%.1f\tscale=%.3f\tbg=#%02X%02X%02X",
                 (inPath as NSString).lastPathComponent, faceW, faceCX, eyeY, scale, bgR, bgG, bgB))
    exit(0)
}
guard !outPath.isEmpty else {
    FileHandle.standardError.write("missing <output.png>\n".data(using: .utf8)!); exit(2)
}

// ---- render ---------------------------------------------------------------
let tx = TARGET_FACE_CX - faceCX * scale
let ty = TARGET_EYE_Y   - eyeY   * scale
guard let ctx = CGContext(data: nil, width: Int(OUT_W), height: Int(OUT_H), bitsPerComponent: 8,
                          bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else { exit(1) }
ctx.interpolationQuality = .high
ctx.setFillColor(red: Double(bgR)/255, green: Double(bgG)/255, blue: Double(bgB)/255, alpha: 1)
ctx.fill(CGRect(x: 0, y: 0, width: OUT_W, height: OUT_H))

func rect(_ x: Double, _ y: Double, _ w: Double, _ h: Double) -> CGRect {   // top-left -> CG
    CGRect(x: x, y: OUT_H - y - h, width: w, height: h)
}
let dw = SW * scale, dh = SH * scale, edge = 2
if ty > 0, let s = img.cropping(to: CGRect(x: 0, y: 0, width: img.width, height: edge)) {
    ctx.draw(s, in: rect(tx, 0, dw, ty))
}
if ty + dh < OUT_H, let s = img.cropping(to: CGRect(x: 0, y: img.height - edge, width: img.width, height: edge)) {
    ctx.draw(s, in: rect(tx, ty + dh, dw, OUT_H - (ty + dh)))
}
if tx > 0, let s = img.cropping(to: CGRect(x: 0, y: 0, width: edge, height: img.height)) {
    ctx.draw(s, in: rect(0, ty, tx, dh))
}
if tx + dw < OUT_W, let s = img.cropping(to: CGRect(x: img.width - edge, y: 0, width: edge, height: img.height)) {
    ctx.draw(s, in: rect(tx + dw, ty, OUT_W - (tx + dw), dh))
}
ctx.draw(img, in: rect(tx, ty, dw, dh))

guard let out = ctx.makeImage(),
      let dest = CGImageDestinationCreateWithURL(URL(fileURLWithPath: outPath) as CFURL,
                                                 UTType.png.identifier as CFString, 1, nil) else { exit(1) }
CGImageDestinationAddImage(dest, out, nil)
guard CGImageDestinationFinalize(dest) else { exit(1) }
print(String(format: "%@  scale=%.3f  faceW %.1f -> %.0f  eyeY %.1f -> %.0f",
             (outPath as NSString).lastPathComponent, scale, faceW, TARGET_FACE_W, eyeY, TARGET_EYE_Y))
