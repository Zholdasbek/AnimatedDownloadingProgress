import UIKit

struct Icon {
    static let iconAnimationView = UIView()
    static let iconView = UIView()
    static let iconImageVeiw = UIImageView()
}

struct Progress {
    static var progressLayerPath = UIBezierPath()
    static var progressLayer = CAShapeLayer()
    static let rotateAnimationKey = "rotation"
    
    static let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
}

class DownloadButtonUIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        
        Progress.progressLayer.lineCap = CAShapeLayerLineCap.round
        Progress.progressLayer.lineWidth = 5
        Progress.progressLayer.fillColor = nil
        Progress.progressLayer.strokeColor = UIColor.darkGray.cgColor
        Progress.progressLayer.strokeEnd = 0.0
        
        Progress.rotateAnimation.duration = 2
        Progress.rotateAnimation.repeatCount = Float.infinity
        Progress.rotateAnimation.fromValue = 0
        Progress.rotateAnimation.toValue = Float(Double.pi * 2)
        Progress.rotateAnimation.repeatCount = Float(TimeInterval.infinity)
        
        
        self.layer.addSublayer(Progress.progressLayer)
        
        self.backgroundColor = .white
        Icon.iconAnimationView.backgroundColor = .white
        Icon.iconView.backgroundColor = UIColor.darkGray
        
        Icon.iconImageVeiw.contentMode = .scaleAspectFit
        Icon.iconImageVeiw.image = UIImage(named: "load")
        
        self.addSubview(Icon.iconView)
        Icon.iconView.addSubview(Icon.iconAnimationView)
        Icon.iconView.mask = Icon.iconImageVeiw
        
        layoutIfNeeded()
        resetAnimationViewToTop()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        createCirclePath()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        Progress.progressLayer.path = Progress.progressLayerPath.cgPath
        Progress.progressLayer.position = center
        
        
        Icon.iconAnimationView.frame = CGRect(x: self.bounds.origin.x, y: -self.bounds.height, width: self.bounds.width, height: self.bounds.height)
        Icon.iconImageVeiw.frame.size = CGSize(width: self.bounds.width/2.5, height: self.bounds.height/2.5)
        Icon.iconView.frame = self.bounds
        
        Icon.iconView.center = center
        Icon.iconImageVeiw.center = center
        
    }
    
    private func resetAnimationViewToTop() {
        Icon.iconAnimationView.frame.origin.y = -self.bounds.height
    }
    private func resetAnimationViewToBottom() {
        Icon.iconAnimationView.frame.origin.y = 0
    }
    private func animateViewTopToBottom() {
        resetAnimationViewToTop()
        UIView.animate(withDuration: 0.4) {
            Icon.iconAnimationView.frame.origin.y = 0
        }
    }
    private func animateViewBottomToTop() {
        resetAnimationViewToBottom()
        UIView.animate(withDuration: 0.4){
            Icon.iconAnimationView.frame.origin.y = -self.bounds.height
        }
    }
    
    private func animateIconSize(){
        Icon.iconImageVeiw.frame.size = CGSize(width: 0, height: 0)
        Icon.iconImageVeiw.frame.origin = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        UIView.animate(withDuration: 0.3) {
            Icon.iconImageVeiw.frame.size = CGSize(width: self.bounds.width/2.5, height: self.bounds.height/2.5)
            Icon.iconImageVeiw.frame.origin = CGPoint(x: self.bounds.width/3.33, y: self.bounds.height/3.33)
        }
    }
    
    func startStopAllAnimations(isStarted: Bool) {
        if isStarted{
            Progress.progressLayer.isHidden = false
            self.animateViewTopToBottom()
            self.startCurvedCircleAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.startRotatingProgress()
                self.animateIconSize()
                self.resetAnimationViewToTop()
                Icon.iconImageVeiw.image = UIImage(named: "stop")
            }
        }
        else {
            Progress.progressLayer.isHidden = true
            self.animateViewBottomToTop()
            self.stopRotatingProgress()
            Progress.progressLayer.strokeEnd = 0.0
            Progress.progressLayer.strokeStart = 0.0
            Icon.iconImageVeiw.image = UIImage(named: "load")
        }
    }
    
    func updateProgress(_ progress: Float) {
        Progress.progressLayer.strokeEnd = 0.18 + CGFloat(progress)
    }
    
    private func startCurvedCircleAnimation() {
        let duration: Float = 20
        var counter: Float = 0
        let pieceOfLayerStrokeEnd: Float = 0.18
        let pieceOfLayerStrokeStart: Float = 0.16
        
        let timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
            DispatchQueue.main.async {
                
                //MARK: Pice of layer to animation curve
                let strokeLength = counter/duration
                
                if counter < duration {
                    if strokeLength <= pieceOfLayerStrokeEnd {
                        Progress.progressLayer.strokeEnd = CGFloat(strokeLength)
                    }
                    let delay = 0.16
                    DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                        Progress.progressLayer.strokeStart = CGFloat(pieceOfLayerStrokeStart)
                    })
                    counter += 1
                } else {
                    timer.invalidate()
                }
            }
        }
        timer.fire()
    }
    
    private func startRotatingProgress() {
        if Progress.progressLayer.animation(forKey: Progress.rotateAnimationKey) == nil {
            Progress.progressLayer.add(Progress.rotateAnimation, forKey: Progress.rotateAnimationKey)
        }
    }
    
    private func stopRotatingProgress() {
        if Progress.progressLayer.animation(forKey: Progress.rotateAnimationKey) != nil {
            Progress.progressLayer.removeAnimation(forKey: Progress.rotateAnimationKey)
        }
    }
    
    private func createCirclePath() {
        let curvingPoint = getCirclePoints(centerPoint: CGPoint.zero, radius: self.bounds.width/2.5, n: 12)
        
        Progress.progressLayerPath.move(to: CGPoint.zero)
        Progress.progressLayerPath.addCurve(to: curvingPoint[4], controlPoint1: CGPoint(x: 0.0, y: curvingPoint[4].y-(curvingPoint[4].y)/4), controlPoint2: CGPoint(x: 0.0, y: curvingPoint[4].y))
        Progress.progressLayerPath.addArc(withCenter: CGPoint.zero, radius: self.bounds.width/2.5, startAngle: CGFloat(Double.pi / 2 + 0.5), endAngle: CGFloat(Double.pi * 2.5 + 0.5), clockwise: true)
    }
    
    private func getCirclePoints(centerPoint point: CGPoint, radius: CGFloat, n: Int)->[CGPoint] {
        let result: [CGPoint] = stride(from: 0.0, to: 360.0, by: Double(360 / n)).map {
            let bearing = CGFloat($0) * .pi / 180
            let x = point.x + radius * cos(bearing)
            let y = point.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        return result
    }
}
