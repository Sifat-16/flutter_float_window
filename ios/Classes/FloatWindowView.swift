//
//  FloatWindowView.swift
//  flutter_float_window
//
//  Created by Kevin Jing on 2023/6/28.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
class FloatWindowView : NSObject,FlutterPlatformView{
    private var _view: UIView
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger?
    ) {
        //          _view = UIView()
        _view = FloatVideoView()
        super.init()
        _view.layer.cornerRadius=14
        _view.clipsToBounds=true
        let channel = FlutterMethodChannelManager.shared.registerMethodChannel(name:"flutter_float_window",binaryMessenger: messenger!)
        channel.setMethodCallHandler { call, result in
            self.handle(call, result: result)
        }
        printE("frame=\(frame)")
        // iOS views can be created here
        printW("args=\(String(describing: args))")
        //          if let paragms = args as? [String:Any]{
        //              let text =  paragms["text"]
        //              printI("flutter传参\(text)")
        //          }
        //          if let XX = args as? Dictionary<String,Any>?{
        //              let text =  XX!["text"]
        //              printI("flutter传参23\(text)")
        //          }
        if args is Dictionary<String,Any>?{
            let dic = args as! Dictionary<String,Any>
            printI("flutter的传参：\(String(describing: dic["text"])),\(String(describing: dic["hello"]))")
            let nativeLabel = UILabel()
            nativeLabel.text = "\(dic["text"] as! String)\(dic["hello"] as! String)"
            nativeLabel.textColor = UIColor.white
            //              nativeLabel.frame=CGRect(x: 0, y: 50, width: 180, height: 50)
            _view.addSubview(nativeLabel)
            
            let url = dic["videoUrl"] as? String
            if let videoUlr=url{
                FloatWindowManager.shared.initFloatWindowManager(videoUrl: videoUlr)
                _view.layer.addSublayer(FloatWindowManager.shared.playerLayerX!)
            }
            _view.addSubview(nativeLabel)
            
        }
    }
    
    func view() -> UIView {
        return _view
    }
    deinit {
        printE("走了吗XXXXX")
    }
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        printD("floatwindowview call method=\(call.method),\(call.arguments)")
        switch (call.method) {
        case "canShowFloatWindow":
            break
        case "showFloatWindow":
            FloatWindowManager.shared.startPip()
            break
        case "hideFloatWindow":
            FloatWindowManager.shared.stopPip()
            break
        case "play":
            FloatWindowManager.shared.play()
            break
        case "pause":
            FloatWindowManager.shared.pause()
            break
        case "seekTo":
            NSLog("seekTo", "seekTo")
            FloatWindowManager.shared.seekTo()
            break
        case "backward":
            FloatWindowManager.shared.backward{ enable in
                if(enable){
                    
                }else{
                    
                }
            }
            break
        case "forward":
            FloatWindowManager.shared.forward{ enable in
                if(enable){}else{}
                
            }
            break
        case "onFullScreenClick":
            FloatWindowManager.shared.onFullScreenClick()
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
}
class FloatVideoView:UIView{
    let forwardContainer = UIView()
    let backwardContainer = UIView()
    let playPauseContainer = UIView()
    let closeContainer = UIView()
    let pipExitContainer = UIView()
    let forwardImageView = UIImageView(image: UIImage(systemName:"goforward.15"))
    let backwardImageView = UIImageView(image: UIImage(systemName:"gobackward.15"))
    let pauseImage = UIImage(systemName:"pause.fill")
    let playImage = UIImage(systemName:"play.fill")
    let playPauseImageView = UIImageView(image:UIImage(systemName:"pause.fill"))
    let pipExitImageView = UIImageView(image: UIImage(systemName:"pip.exit"))
    let closeImageView = UIImageView(image: UIImage(systemName:"xmark"))
    let stackView = UIStackView()
    var playerLayer:AVPlayerLayer?
    private var videoUrl: String=""
    init(frame: CGRect,videoUrl:String) {
        self.videoUrl=videoUrl;
        super.init(frame: frame)
        debugPrint("zou le ma~==========================12==")
    }
    override init(frame: CGRect) {
        self.videoUrl = ""
        super.init(frame:frame)
        debugPrint("zou le ma~============================")

        pipExitImageView.tintColor = UIColor.white
        closeImageView.tintColor = UIColor.white
        
        pipExitContainer.addSubview(pipExitImageView)
        pipExitImageView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            pipExitImageView.widthAnchor.constraint(equalToConstant: 25),
            pipExitImageView.heightAnchor.constraint(equalToConstant: 20),
            pipExitImageView.centerXAnchor.constraint(equalTo: pipExitContainer.centerXAnchor),
            pipExitImageView.centerYAnchor.constraint(equalTo: pipExitContainer.centerYAnchor)
        ])
        closeContainer.addSubview(closeImageView)
        closeImageView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            closeImageView.widthAnchor.constraint(equalToConstant: 20),
            closeImageView.heightAnchor.constraint(equalToConstant: 22),
            closeImageView.centerXAnchor.constraint(equalTo: closeContainer.centerXAnchor),
            closeImageView.centerYAnchor.constraint(equalTo: closeContainer.centerYAnchor)
        ])
        
        self.addSubview(pipExitContainer)
        self.addSubview(closeContainer)
        pipExitContainer.translatesAutoresizingMaskIntoConstraints=false
        closeContainer.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            pipExitContainer.widthAnchor.constraint(equalToConstant: 45),
            pipExitContainer.heightAnchor.constraint(equalToConstant: 40),
            pipExitContainer.topAnchor.constraint(equalTo: self.topAnchor,constant: 0),
            pipExitContainer.rightAnchor.constraint(equalTo: self.rightAnchor,constant: 0),
        
            closeContainer.widthAnchor.constraint(equalToConstant: 40),
            closeContainer.heightAnchor.constraint(equalToConstant: 42),
            closeContainer.topAnchor.constraint(equalTo: self.topAnchor,constant: 0),
            closeContainer.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 0),
        ])
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        
        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor,constant: 0),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor,constant: 0),
            stackView.topAnchor.constraint(equalTo: self.topAnchor,constant: 60),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: 0),
        ])
        
        forwardImageView.tintColor = UIColor.white
        backwardImageView.tintColor = UIColor.white
        playPauseImageView.tintColor = UIColor.white
        
        forwardContainer.addSubview(forwardImageView)
        forwardImageView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            forwardImageView.widthAnchor.constraint(equalToConstant: 25),
            forwardImageView.heightAnchor.constraint(equalToConstant: 25),
            forwardImageView.centerXAnchor.constraint(equalTo: forwardContainer.centerXAnchor),
            forwardImageView.centerYAnchor.constraint(equalTo: forwardContainer.centerYAnchor)
        ])
        
        backwardContainer.addSubview(backwardImageView)
        backwardImageView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            backwardImageView.widthAnchor.constraint(equalToConstant: 25),
            backwardImageView.heightAnchor.constraint(equalToConstant: 25),
            backwardImageView.centerXAnchor.constraint(equalTo: backwardContainer.centerXAnchor),
            backwardImageView.centerYAnchor.constraint(equalTo: backwardContainer.centerYAnchor)
        ])
        
        playPauseContainer.addSubview(playPauseImageView)
        playPauseImageView.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            playPauseImageView.widthAnchor.constraint(equalToConstant: 25),
            playPauseImageView.heightAnchor.constraint(equalToConstant: 30),
            playPauseImageView.centerXAnchor.constraint(equalTo: playPauseContainer.centerXAnchor),
            playPauseImageView.centerYAnchor.constraint(equalTo: playPauseContainer.centerYAnchor)
        ])
        
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(backwardContainer)
        stackView.addArrangedSubview(playPauseContainer)
        stackView.addArrangedSubview(forwardContainer)
        stackView.addArrangedSubview(UIView())
        
        forwardContainer.translatesAutoresizingMaskIntoConstraints=false
        backwardContainer.translatesAutoresizingMaskIntoConstraints=false
        playPauseContainer.translatesAutoresizingMaskIntoConstraints=false
        NSLayoutConstraint.activate([
            forwardContainer.widthAnchor.constraint(equalToConstant: 45),
            forwardContainer.heightAnchor.constraint(equalToConstant: 45),
            backwardContainer.widthAnchor.constraint(equalToConstant: 45),
            backwardContainer.heightAnchor.constraint(equalToConstant: 45),
            playPauseContainer.widthAnchor.constraint(equalToConstant: 45),
            playPauseContainer.heightAnchor.constraint(equalToConstant: 50),
        ])

//        let currentViewClick = UITapGestureRecognizer(target: self, action: #selector(onCurrentViewClick))
//        self.isUserInteractionEnabled=true
//        self.addGestureRecognizer(currentViewClick)
        
        let playPauseClick = UITapGestureRecognizer(target: self, action: #selector(onPlayPauseClick))
        playPauseContainer.isUserInteractionEnabled=true
        playPauseContainer.addGestureRecognizer(playPauseClick)
        
        let forwardClick = UITapGestureRecognizer(target: self, action: #selector(onForwardClick))
        forwardContainer.isUserInteractionEnabled=true
        forwardContainer.addGestureRecognizer(forwardClick)
        
        let backwardClick = UITapGestureRecognizer(target: self, action: #selector(onBackwardClick))
        backwardContainer.isUserInteractionEnabled=true
        backwardContainer.addGestureRecognizer(backwardClick)
        
        let fullScreenClick = UITapGestureRecognizer(target: self, action: #selector(onFullScreenClick))
        pipExitContainer.isUserInteractionEnabled=true
        pipExitContainer.addGestureRecognizer(fullScreenClick)
        
        let closeClick = UITapGestureRecognizer(target: self, action: #selector(onCloseClick))
        closeContainer.isUserInteractionEnabled=true
        closeContainer.addGestureRecognizer(closeClick)
        
        
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        print("current frame: \(self.frame)")
        FloatWindowManager.shared.playerLayerX?.frame=frame
        super.layoutSubviews()

        self.addSubview(pipExitContainer)
        self.addSubview(closeContainer)
        self.addSubview(stackView)
        
    }
    
    deinit {
        printE("是否走了deinit")
    }
    
    @objc func onCloseClick(){
        FloatWindowManager.shared.onCloseClick()
        
    }
    @objc func onFullScreenClick(){
        printE("onFullScreenClick")
        FloatWindowManager.shared.onFullScreenClick()
        
    }
    @objc func onForwardClick(){
        FloatWindowManager.shared.backward{ enable in
            if(enable){
                forwardImageView.tintColor=UIColor.white
            }else{
                forwardImageView.tintColor=UIColor.white.withAlphaComponent(0.5)
            }
        }
    }
    @objc func onBackwardClick(){
        FloatWindowManager.shared.backward{ enable in
            if(enable){
                backwardImageView.tintColor=UIColor.white
            }else{
                backwardImageView.tintColor=UIColor.white.withAlphaComponent(0.5)
            }
        }
    }
    @objc func onPlayPauseClick(){
        if(FloatWindowManager.shared.isPlaying){
            FloatWindowManager.shared.pause()
            playPauseImageView.image = playImage
        }else{
            FloatWindowManager.shared.play()
            playPauseImageView.image = pauseImage
        }
        
    }
    @objc func onCurrentViewClick(){
        printE("onCurrentViewClick")
        
    }
}

//extension FloatWindowView: AVPictureInPictureControllerDelegate{
//    func pictureInPictureController(_ pictureInPictureController: AVPictureInPictureController, failedToStartPictureInPictureWithError error: Error) {
//        printE("pictureInPictureController erro=\(error)")
//    }
//    func pictureInPictureControllerWillStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//
//    }
//    func pictureInPictureControllerDidStartPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//
//    }
//    func pictureInPictureControllerWillStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//
//    }
//    func pictureInPictureControllerDidStopPictureInPicture(_ pictureInPictureController: AVPictureInPictureController) {
//
//    }
//}
