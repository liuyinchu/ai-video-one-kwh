import Foundation
import AVFoundation
import CoreVideo
import CoreMedia
import CoreGraphics
let root = URL(fileURLWithPath:"/Users/yangshuyun/workspace/dev/ai-video/ai-video-1024-astra/build/probe")
let fm = FileManager.default
func u(_ s:String)->URL{root.appendingPathComponent(s)}
func sec(_ t:CMTime)->Double{CMTimeGetSeconds(t)}
func fourCC(_ c:FourCharCode)->String{String(bytes:[UInt8((c>>24)&255),UInt8((c>>16)&255),UInt8((c>>8)&255),UInt8(c&255)],encoding:.ascii)!}
func inspect(_ file:String){
 let a=AVURLAsset(url:u(file));print("ASSET",file,sec(a.duration))
 for t in a.tracks {print("TRACK",t.mediaType.rawValue,"start",sec(t.timeRange.start),"dur",sec(t.timeRange.duration),"end",sec(t.timeRange.end),"codecs",t.formatDescriptions.map{fourCC(CMFormatDescriptionGetMediaSubType($0 as! CMFormatDescription))})}
}
func makeVideo() throws {
 let file=u("tail-silent.mp4");try? fm.removeItem(at:file)
 let w=try AVAssetWriter(outputURL:file,fileType:.mp4)
 let i=AVAssetWriterInput(mediaType:.video,outputSettings:[AVVideoCodecKey:AVVideoCodecType.h264,AVVideoWidthKey:320,AVVideoHeightKey:180]);i.expectsMediaDataInRealTime=false
 let a=AVAssetWriterInputPixelBufferAdaptor(assetWriterInput:i,sourcePixelBufferAttributes:[kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA,kCVPixelBufferWidthKey as String:320,kCVPixelBufferHeightKey as String:180,kCVPixelBufferCGImageCompatibilityKey as String:true,kCVPixelBufferCGBitmapContextCompatibilityKey as String:true])
 w.add(i);guard w.startWriting() else {throw w.error!};w.startSession(atSourceTime:.zero)
 for n in 0..<192 { autoreleasepool {while !i.isReadyForMoreMediaData{Thread.sleep(forTimeInterval:0.001)}; var b:CVPixelBuffer?;CVPixelBufferPoolCreatePixelBuffer(nil,a.pixelBufferPool!,&b);let p=b!;CVPixelBufferLockBaseAddress(p,[]);memset(CVPixelBufferGetBaseAddress(p),0,CVPixelBufferGetDataSize(p));CVPixelBufferUnlockBaseAddress(p,[]);if !a.append(p,withPresentationTime:CMTime(value:Int64(n),timescale:24)){fatalError("append failed")}}}
 w.endSession(atSourceTime:CMTime(value:192,timescale:24));i.markAsFinished();let s=DispatchSemaphore(value:0);w.finishWriting{s.signal()};s.wait();guard w.status == .completed else {throw w.error!}
}
func run(_ padded:Bool) throws {
 let c=AVMutableComposition();let v=c.addMutableTrack(withMediaType:.video,preferredTrackID:kCMPersistentTrackID_Invalid)!;let a=c.addMutableTrack(withMediaType:.audio,preferredTrackID:kCMPersistentTrackID_Invalid)!
 let va=AVURLAsset(url:u("tail-silent.mp4"));let aa=AVURLAsset(url:u("tingting-220.aiff"));let duration=CMTime(seconds:8,preferredTimescale:60000)
 try v.insertTimeRange(CMTimeRange(start:.zero,duration:duration),of:va.tracks(withMediaType:.video).first!,at:.zero)
 try a.insertTimeRange(CMTimeRange(start:.zero,duration:aa.duration),of:aa.tracks(withMediaType:.audio).first!,at:CMTime(seconds:0.45,preferredTimescale:60000))
 print("BEFORE PAD",padded,sec(a.timeRange.start),sec(a.timeRange.end))
 if padded {let end=a.timeRange.end;a.insertEmptyTimeRange(CMTimeRange(start:end,duration:CMTimeSubtract(duration,end)))}
 print("COMPOSITION",padded,sec(c.duration),sec(a.timeRange.start),sec(a.timeRange.end))
 let p=AVMutableAudioMixInputParameters(track:a);p.setVolume(0.95,at:.zero);let m=AVMutableAudioMix();m.inputParameters=[p]
 let e=AVAssetExportSession(asset:c,presetName:AVAssetExportPreset1920x1080)!;let name=padded ? "tail-padded.mp4":"tail-unpadded.mp4";try? fm.removeItem(at:u(name));e.outputURL=u(name);e.outputFileType = .mp4;e.audioMix=m;e.timeRange=CMTimeRange(start:.zero,duration:duration)
 let s=DispatchSemaphore(value:0);e.exportAsynchronously{s.signal()};s.wait();guard e.status == .completed else {throw e.error!};inspect(name)
}
do {try makeVideo();inspect("tail-silent.mp4");try run(false);try run(true)}catch{print("FAILED",error);exit(1)}
