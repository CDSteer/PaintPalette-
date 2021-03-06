//  ViewController.swift
//  IOS10DrawShapesTutorial
//
//  Created by Cameron Steer on 05/05/2017.
//  Copyright © 2017 Cameron Steer. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    struct coordinates {
        var x: Int
        var y: Int
    }
    
    struct onCanvasPaintsLink {
        var paintSection:UIView
        var onCanvasPaint:[UIView]
    }
    
    var onCanvasPaintsLinks:[onCanvasPaintsLink] = []
    
    var isTouching:Bool = false
    var bluetoothIO: BluetoothIO!
    @IBOutlet weak var dataLbl: UILabel!
    let paletteW:Int = 40
    let paletteH:Int = 40

    let paintBlue: UIView = UIView()
    let paintRed: UIView = UIView()
    let paintGreen: UIView = UIView()
    var spread:Bool = false
    var brushColor:CGColor = UIColor.init(red: CGFloat(0), green: CGFloat(0), blue: CGFloat(0), alpha: 0).cgColor
    var newColour:UIColor = UIColor()
    var touchingscreen:Bool = false
    var longPressed = false
    var selectedRow = 0
    
    var longPressBeginTime: TimeInterval = 0.0
    var gestureTime:Float = 0.0
    
    var lines: [Line] = []
    var lastPoint: CGPoint!
    
    
    var swipeDirects:[Bool] = [false,false,false,false,false,false,false,false,false]
    let DUPLEFT:Int = 0
    let DLEFT:Int = 1
    let DDOWNLEFT:Int = 2
    let DUP:Int = 3
    let CENTURE:Int = 4
    let DDOWN:Int = 5
    let DUPRIGHT:Int = 6
    let DRIGHT:Int = 7
    let DDOWNRIGHT:Int = 8

    var paintSections = [UIView]()

    var onScreenPaints = [CAShapeLayer]()
    var onCanvasPaints = [UIView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // paintRed.backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        // paintRed.frame = CGRect(x: 50, y: 100, width: 50, height: 50)
        
        // paintGreen.backgroundColor = UIColor.init(red: 0, green: 255, blue: 0, alpha: 1)
        // paintGreen.frame = CGRect(x: 150, y: 100, width: 50, height: 50)
        
        
        // paintBlue.backgroundColor = UIColor.init(red: 0, green: 0, blue: 255, alpha: 1)
        // paintBlue.frame = CGRect(x: 250, y: 100, width: 50, height: 50)
        
        // self.view.addSubview(paintRed)
        // self.view.addSubview(paintGreen)
        // self.view.addSubview(paintBlue)
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(normalTap(_:)))
//        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap(_:)))
//        tapGesture.numberOfTapsRequired = 1
//        self.view.addGestureRecognizer(tapGesture)
//        self.view.addGestureRecognizer(longGesture)
        
//        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeRight.direction = UISwipeGestureRecognizerDirection.right
//        self.view.addGestureRecognizer(swipeRight)
//        
//        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
//        swipeDown.direction = UISwipeGestureRecognizerDirection.down
//        self.view.addGestureRecognizer(swipeDown)
        
        paintSectionSetUp()
        
        // Do any additional setup after loading the view, typically from a nib.
        
        if (bluetoothIO != nil) {
            print(bluetoothIO)
            bluetoothIO.delegate = self
        } else {
            bluetoothIO = BluetoothIO(serviceUUID: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E", delegate: self)
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func paintSectionSetUp() {
        
        var xPlace:Int = 0
        var yPlace:Int = 50

        //drawCircle(CGPoint(x: 10, y: 10), paintColour: UIColor.red.cgColor)
        // drawCircle(touchPoint: CGPoint(x: 10, y: 10), paintColour: UIColor.red.cgColor, paintSectionsIndex: get1DPoint(x: 10, y: 10))
        
        for y in 0...paletteH {
            for x in 0...paletteW {
                let i:Int = x+(y*paletteW)
                paintSections.append(UIView())
                paintSections[i].frame = CGRect(x: xPlace, y: yPlace, width: 10, height: 10)
                paintSections[i].backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 1)
                
                self.view.addSubview(paintSections[i])
                onCanvasPaintsLinks.append(onCanvasPaintsLink(paintSection: UIView(), onCanvasPaint: [UIView]()))
                
                xPlace = xPlace+10
                if (xPlace>paletteW*10){
                    yPlace = yPlace+10
                    xPlace=0
                }
            }
        }
        
//        paintSections[0].backgroundColor = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
//        for _ in 0...250{
//            drawCircle(CGPoint(x: paintSections[0].frame.origin.x+5, y: paintSections[0].frame.origin.y+5), paintColour: (paintSections[0].backgroundColor?.cgColor)!)
//        }
//        paintSections[1].backgroundColor = UIColor.init(red: 0, green: 255, blue: 0, alpha: 1)
//        for _ in 0...250{
//            drawCircle(CGPoint(x: paintSections[1].frame.origin.x+5, y: paintSections[1].frame.origin.y+5), paintColour: (paintSections[1].backgroundColor?.cgColor)!)
//        }
//        paintSections[2].backgroundColor = UIColor.init(red: 0, green: 0, blue: 225, alpha: 1)
//        for _ in 0...250{
//            drawCircle(CGPoint(x: paintSections[2].frame.origin.x+5, y: paintSections[2].frame.origin.y+5), paintColour: (paintSections[2].backgroundColor?.cgColor)!)
//        }
        
        drawPaintsections()
        
    }
    
    func drawPaintsections() {
        for i in 0...paletteW {
            for j in 0...paletteH {
                self.view.addSubview(paintSections[i*j])
            }
        }
        drawPots()
    }
    
    
    var pots:[CAShapeLayer] = [CAShapeLayer(),CAShapeLayer(),CAShapeLayer()]
    func drawPots() {
        let colors:[UIColor] = [UIColor.red,UIColor.green,UIColor.blue]
        for i in 1...colors.count{
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: i*95, y: 95), radius: CGFloat(20), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = colors[i-1].cgColor
            view.layer.addSublayer(shapeLayer)
            pots[i-1] = shapeLayer
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        isTouching = true
        lastPoint = touches.first?.location(in: self.view)
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            //print(position.x)
            //print(position.y)
            
            paintSeletion(position: position)
            spread = true
            
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(position)){
                        
                        let newColour:CGColor = (paintSections[i].backgroundColor?.cgColor)!
                        let components:[CGFloat] = newColour.components!
                        
                        let newColor:[Float] = reverseColors(colors: components)
                        
                        brushColor = UIColor.init(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1).cgColor
                        
                        // let newBrushColour:CGColor = brushColor
                        
                        // let newBrushColourComponents:[CGFloat] = newBrushColour.components!
                        
//                        print("red",newBrushColourComponents[0]*255)
//                        print("green",newBrushColourComponents[1]*255)
//                        print("blue",newBrushColourComponents[2]*255)
                        
                    }
                }
            }
            for i in 0...pots.count-1{
                if (pots[i].path!.contains(position)) {
                    brushColor = pots[i].fillColor!
                }
            }
            
        }
    }
    
    func reverseColors(colors: [CGFloat]) -> [Float] {
        var color:[Float]=[0,0,0]
//        print("reverseColors:red", colors[0])
//        print("reverseColors:green", colors[1])
//        print("reverseColors:blue", colors[2])
        
        color[0]=(255 - (255-Float(colors[0])))
        color[1]=(255 - (255-Float(colors[1])))
        color[2]=(255 - (255-Float(colors[2])))
        
//        print("reverseColor:red", color[0])
//        print("reverseColor:green", color[1])
//        print("reverseColor:blue", color[2])
        return color
    }
    
    func printCGColor(myCGCOLOR:CGColor) {
        let testComponents:[CGFloat] = myCGCOLOR.components!
        print("color R:",testComponents[0])
        print("color G:",testComponents[1])
        print("color B:",testComponents[2])
    }
    
    var colourCounts: [Int] = [0,0,0]
    
    func colourSquare(p:Int, animateColour:Bool) {
        

        for onCanvasPaint in onCanvasPaintsLinks[p].onCanvasPaint {
            //if (paintSections[p].frame.contains(CGPoint(x: (onCanvasPaint.frame.origin.x), y: (onCanvasPaint.frame.origin.y)))){
            colourCount(onCanvasPaint: onCanvasPaint)
                // printCGColor(myCGCOLOR: (onCanvasPaint.backgroundColor?.cgColor)!)
            // }
            var newRed:Float
            var newGreen:Float
            var newBlue:Float
            
            newRed = map(value: Float((Float(colourCounts[0])/Float(10))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
            newGreen = map(value: Float((Float(colourCounts[1])/Float(10))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
            newBlue = map(value: Float((Float(colourCounts[2])/Float(10))*100), istart: 0, istop: 100, ostart: 0, ostop: 255)
            
            
            var a:CGFloat = 1.0
            if (newRed>0){ a = CGFloat(map(value: newRed, istart: 0, istop: 255, ostart: 0, ostop: 1)) }
            if (newGreen>0){ a = CGFloat(map(value: newGreen, istart: 0, istop: 255, ostart: 0, ostop: 1)) }
            if (newBlue>0){ a = CGFloat(map(value: newBlue, istart: 0, istop: 255, ostart: 0, ostop: 1)) }
            
            newColour = UIColor.init(red: CGFloat(newRed)/255, green: CGFloat(newGreen)/255, blue: CGFloat(newBlue)/255, alpha: a)
            // lightColour = UIColor.init(red: CGFloat(newRed)/255, green: CGFloat(newGreen)/255, blue: CGFloat(newBlue)/255, alpha: a-0.2)
            
            if (animateColour==true) {
                UIView.animate(withDuration: 5.0, delay: 0.0, options:[UIViewAnimationOptions.repeat, UIViewAnimationOptions.autoreverse], animations: {
                    self.paintSections[p].layer.backgroundColor = self.paintSections[p].layer.backgroundColor
                    self.paintSections[p].layer.backgroundColor = self.newColour.cgColor
                }, completion:nil)
            
            }else{
                paintSections[p].backgroundColor = newColour
            }
        }
        colourCounts = [0,0,0]
    }
    
    
    
    func colourCount(onCanvasPaint:UIView){
        let newColour:CGColor = (onCanvasPaint.backgroundColor?.cgColor)!
        let components:[CGFloat] = newColour.components!
        if ((components[0])>0.0){ colourCounts[0] = colourCounts[0] + 1}
        if ((components[1])>0.0){ colourCounts[1] = colourCounts[1] + 1}
        if ((components[2])>0.0){ colourCounts[2] = colourCounts[2] + 1}
    }
    
    func setTouchDirection(newTouchCoordinates:coordinates, prevTouchCoordinates:coordinates ) {
        for i in 0...swipeDirects.count-1 {
            if ((newTouchCoordinates.x == prevTouchCoordinates.x + directions[i].x && newTouchCoordinates.y == prevTouchCoordinates.y + directions[i].y)){
                swipeDirects[i] = true
            }
        }
    }
    func setTouchDirection2(newTouchCoordinates:coordinates, prevTouchCoordinates:coordinates ) {
        for i in 0...swipeDirects.count-1 {
            if ((newTouchCoordinates.x >= prevTouchCoordinates.x + directions[i].x && newTouchCoordinates.y >= prevTouchCoordinates.y + directions[i].y)){
                swipeDirects[i] = true
            } else if ((newTouchCoordinates.x <= prevTouchCoordinates.x + directions[i].x && newTouchCoordinates.y <= prevTouchCoordinates.y + directions[i].y)){
                swipeDirects[i] = true
            }
        }
    }
    
    var offSet:Int = 1
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let newPoint = touches.first?.location(in: self.view)
        lines.append(Line(start: lastPoint, end: newPoint!))
        
        setTouchDirection(newTouchCoordinates: coordinates(x: Int(touches.first!.location(in: self.view).x), y: Int(touches.first!.location(in: self.view).y)), prevTouchCoordinates: coordinates(x: Int(touches.first!.previousLocation(in: self.view).x), y: Int(touches.first!.previousLocation(in: self.view).y)))
        
        if let touch = touches.first {
            let position = touch.location(in: self.view)
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(position)){
                        drawCircle(touchPoint: position, paintColour: brushColor, paintSectionsIndex: i)
                        for onCanvasPaint in onCanvasPaintsLinks[i].onCanvasPaint {
                            if (onCanvasPaint.frame.contains(position)){
                                onCanvasPaintsLinks[i].onCanvasPaint.remove(at: onCanvasPaintsLinks[i].onCanvasPaint.index(of:onCanvasPaint)!)
                            }
                        }
                        
                        let activeAdjacents:[coordinates] = getAdjacentValues(x: i%paletteW, y: (i-x)/paletteW, offSet: offSet)
                        for activeAdjacent in activeAdjacents {
                            let p = get1DPoint(x: activeAdjacent.x, y:activeAdjacent.y)
                            if (p != i && p>0){
                                // print("Point x: ", get2DPoint(point: p).x, "y: ", get2DPoint(point:p).y)
                                let x:Int = 5
                                let y:Int = 5
//                                for _ in 1...2 {
//                                    for _ in 1...2 {
                                        drawCircle(touchPoint: CGPoint(x: paintSections[p].frame.origin.x+CGFloat(x), y: paintSections[p].frame.origin.y+CGFloat(y)), paintColour: brushColor, paintSectionsIndex: p)
//                                        y = y+1
//                                        if (y>5){
//                                            x = x+1
//                                            y=0
//                                        }
//                                    }
//                                }
                                colourSquare(p:p, animateColour: false)
                            }
                            colourSquare(p:i, animateColour: false)
                        }
                    }
                }
            }

            // if (isTouching){ offSet = offSet + 1 }
        }
        
        // drawLineFromPoint(start: lastPoint, toPoint: newPoint!, ofColor: UIColor.init(red: (brushColor.components?[0])!, green: (brushColor.components?[1])!, blue: (brushColor.components?[2])!, alpha: 1), inView: self.view)
        
        lastPoint = touches.first?.location(in: self.view)
        for i in 0...swipeDirects.count-1 {
            swipeDirects[i] = false
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        spread = false
        isTouching = false
    }
    
    func get2DPoint(point:Int) -> coordinates {
        return coordinates(x: (point%paletteW)+5, y: ((point-(point%paletteW))/paletteW)+5)
    }
    
    func get1DPoint(x:Int, y:Int)-> Int{
        return x+(y*paletteW)
    }

    let directions = [coordinates(x: -1, y: -1),coordinates(x: -1,y: 0),coordinates(x: -1,y: 1),coordinates(x: 0,y: -1), coordinates(x: 0,y: 0), coordinates(x: 0,y: 1),coordinates(x: 1,y: -1),coordinates(x: 1,y: 0),coordinates(x: 1,y: 1)];
    let directionsRight = [coordinates(x: 0,y: 0), coordinates(x: 0, y: -1),  coordinates(x: 1,y: -1),  coordinates(x: 1,y: 0),  coordinates(x: 1,y: 1),  coordinates(x: 0,y: 1), coordinates(x:2, y:0)];
    let directionsLeft =  [coordinates(x: 0,y: 0), coordinates(x: 0, y: -1), coordinates(x: -1,y: -1),  coordinates(x: -1,y: 0),  coordinates(x: -1,y: 1),  coordinates(x: 0,y: 1), coordinates(x:-2, y:0)];
    let directionsDown =  [coordinates(x: 0,y: 0), coordinates(x: -1, y: 0), coordinates(x: -1,y: 1),   coordinates(x: 0,y: 1), coordinates(x: 1,y: 1),  coordinates(x: 1,y: 0), coordinates(x:0, y:2)];
    let directionsUp =    [coordinates(x: 0,y: 0), coordinates(x: -1,y: 0),  coordinates(x: -1,y: -1), coordinates(x: 0,y: -1), coordinates(x: 1,y: -1), coordinates(x: 1,y: 0), coordinates(x:0, y:-2)];
    
    func getAdjacentValues(x:Int, y:Int, offSet:Int) -> [coordinates] {
        var activeAdjacents: [coordinates] = []
        if (swipeDirects[DRIGHT] == true){
            for i in 0...directionsRight.count-1 {
                activeAdjacents.append(coordinates(x: 0, y: 0))
                activeAdjacents[i].x = x + directionsRight[i].x;
                activeAdjacents[i].y = y + directionsRight[i].y;
            }
        } else if (swipeDirects[DUP] == true) {
            for i in 0...directionsUp.count-1 {
                activeAdjacents.append(coordinates(x: 0, y: 0))
                activeAdjacents[i].x = x + directionsUp[i].x;
                activeAdjacents[i].y = y + directionsUp[i].y;
            }
            
        } else if (swipeDirects[DLEFT] == true){
            for i in 0...directionsLeft.count-1 {
                activeAdjacents.append(coordinates(x: 0, y: 0))
                activeAdjacents[i].x = x + directionsLeft[i].x;
                activeAdjacents[i].y = y + directionsLeft[i].y;
            }
            
        } else if (swipeDirects[DDOWN] == true){
            for i in 0...directionsDown.count-1 {
                activeAdjacents.append(coordinates(x: 0, y: 0))
                activeAdjacents[i].x = x + directionsDown[i].x;
                activeAdjacents[i].y = y + directionsDown[i].y;
            }
    
        }
        return activeAdjacents
    }
    
    func drawCircle(touchPoint:CGPoint, paintColour:CGColor, paintSectionsIndex:Int){
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: touchPoint.x/2, y: touchPoint.y/2), radius: CGFloat(10), startAngle: CGFloat(0), endAngle:CGFloat(Double.pi * 2), clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        //change the fill color
        shapeLayer.fillColor = paintColour
        onScreenPaints.append(shapeLayer)
        
        // view.layer.addSublayer(CGRect(x: touchPoint.x, y: touchPoint, width: 1, height: 1))
        let k = UIView()
        
        k.frame = CGRect(x: touchPoint.x/2, y: touchPoint.y/2, width: 5, height: 5)
        k.backgroundColor = UIColor.init(red: (paintColour.components?[0])!, green: (paintColour.components?[1])!, blue: (paintColour.components?[2])!, alpha: 1)
        // onCanvasPaints.append(k)
        onCanvasPaintsLinks[paintSectionsIndex].onCanvasPaint.append(k)

        // print(onCanvasPaintsLinks[0])
        // self.view.addSubview(k)
    }
    
    
    func paintSeletion(position: CGPoint) {
        let isPointInRed:Bool = paintRed.frame.contains(position)
        let isPointInGreen:Bool = paintGreen.frame.contains(position)
        let isPointInBlue:Bool = paintBlue.frame.contains(position)
        
        if (isPointInRed == true){
            brushColor = UIColor.red.cgColor
            spread = true
        }
        if (isPointInGreen == true){
            brushColor = UIColor.green.cgColor
            spread = true
        }
        if (isPointInBlue == true){
            brushColor = UIColor.blue.cgColor
            spread = true
        }
        
    }
    
    

    
    var splitString = [String]()
    var lastPosition:coordinates = coordinates(x: 0, y: 0)
    var currentPosition:coordinates = coordinates(x: 0, y: 0)
    
    func hardwareTouch(position:coordinates, firstTouch:Bool) {
        let positionCG:CGPoint = CGPoint(x: position.x, y:position.y)
        paintSeletion(position: positionCG)
        
        if (firstTouch == true) {
            spread = true
            for y in 0...paletteH {
                for x in 0...paletteW {
                    let i:Int = x+(y*paletteW)
                    if (paintSections[i].frame.contains(positionCG)){
                        let newColour:CGColor = (paintSections[i].backgroundColor?.cgColor)!
                        let components:[CGFloat] = newColour.components!
                        let newColor:[Float] = reverseColors(colors: components)
                        brushColor = UIColor.init(red: CGFloat(newColor[0]), green: CGFloat(newColor[1]), blue: CGFloat(newColor[2]), alpha: 1).cgColor
                    }
                }
            }
            for i in 0...pots.count-1{
                if (pots[i].path!.contains(positionCG)) {
                    brushColor = pots[i].fillColor!
                }
            }
        }

        setTouchDirection(newTouchCoordinates: currentPosition, prevTouchCoordinates: lastPosition)
        // drawCircle(touchPoint: positionCG, paintColour: brushColor, paintSectionsIndex: get1DPoint(x: position.x, y: position.y))
        paintSeletion(position: positionCG)

        for y in 0...paletteH {
            for x in 0...paletteW {
                let i:Int = x+(y*paletteW)
                if (paintSections[i].frame.contains(positionCG)){
                    drawCircle(touchPoint: positionCG, paintColour: brushColor, paintSectionsIndex: i)
                    for onCanvasPaint in onCanvasPaintsLinks[i].onCanvasPaint {
                        if (onCanvasPaint.frame.contains(positionCG)){
                            onCanvasPaintsLinks[i].onCanvasPaint.remove(at: onCanvasPaintsLinks[i].onCanvasPaint.index(of:onCanvasPaint)!)
                        }
                    }
                    
                    let activeAdjacents:[coordinates] = getAdjacentValues(x: i%paletteW, y: (i-x)/paletteW, offSet: offSet)
                    for activeAdjacent in activeAdjacents {
                        let p = get1DPoint(x: activeAdjacent.x, y:activeAdjacent.y)
                        if (p != i && p>0){
                            let x:Int = 5
                            let y:Int = 5
                            drawCircle(touchPoint: CGPoint(x: paintSections[p].frame.origin.x+CGFloat(x), y: paintSections[p].frame.origin.y+CGFloat(y)), paintColour: brushColor, paintSectionsIndex: p)
                            colourSquare(p:p, animateColour: false)
                        }
                        colourSquare(p:i, animateColour: false)
                    }
                }
            }
        }
        
        for i in 0...swipeDirects.count-1 {
            swipeDirects[i] = false
        }
        spread = false
    }
    
    let screenSize = UIScreen.main.bounds
    var tPointMapped:coordinates = coordinates(x: 0, y:0)
    
    func showValues(_ fullString: String) {
        let tPoint:coordinates = coordinates(x: Int(splitString[0])!, y: Int(splitString[1])!)
        currentPosition = tPoint
        tPointMapped.x = Int(map(value: Float(tPoint.x), istart: 0, istop: 40, ostart: 0, ostop: Float(screenSize.width)))
        tPointMapped.y = Int(map(value: Float(tPoint.y), istart: 0, istop: 35, ostart: 10, ostop: Float(screenSize.height)))
        // print("LastPosition", lastPosition.x, lastPosition.y)
        // print("currentPosition", currentPosition.x, currentPosition.y)
        
        if (currentValues == lastValues) {
            hardwareTouch(position: tPointMapped, firstTouch: true)
        }else{
            hardwareTouch(position: tPointMapped, firstTouch: false)
        }
        lastPosition = tPoint
    }

    func splitString(_ fullString: String) {
        splitString = fullString.components(separatedBy: ";")
    }
    
    var currentValues:String = ""
    var lastValues:String = ""
    
    func recievedValues(_ value: String) {
        print("recievedValues:", value)
        splitString(value)
        currentValues = value
        if (Int(splitString[2])! < 100) {
            showValues(value)
        }
        lastValues = value
        
    }
    
    func map(value:Float, istart:Float, istop:Float, ostart:Float, ostop:Float) -> Float {
        return ostart + (ostop - ostart) * ((value - istart) / (istop - istart))
    }
    
    @IBAction func clearTaped(){
        viewDidLoad()
    }
}


extension ViewController: BluetoothIODelegate {
    func bluetoothIO(_ bluetoothIO: BluetoothIO, didReceiveValue value: String) {
        self.recievedValues(value)
    }
}

extension CALayer {
    
    func colorOfPoint(point:CGPoint) -> CGColor {
        
        var pixel: [CUnsignedChar] = [0, 0, 0, 0]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        
        self.render(in: context!)
        
        let red: CGFloat   = CGFloat(pixel[0]) / 255.0
        let green: CGFloat = CGFloat(pixel[1]) / 255.0
        let blue: CGFloat  = CGFloat(pixel[2]) / 255.0
        let alpha: CGFloat = CGFloat(pixel[3]) / 255.0
        
        let color = UIColor(red:red, green: green, blue:blue, alpha:alpha)
        
        return color.cgColor
    }
}


