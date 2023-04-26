//
//  DPCCBaseController.swift
//  DPCCDemo
//
//  Created by 李旺 on 2022/11/29.
//

import UIKit
import WebKit

class DPCCBaseController: UIViewController {

    var webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypes(rawValue: 0)
        let web = WKWebView.init(frame: CGRect(origin: CGPoint.init(x: 0, y: UIApplication.shared.statusBarFrame.height), size: UIScreen.main.bounds.size), configuration: configuration)
        web.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        web.allowsBackForwardNavigationGestures = true
        web.backgroundColor = .white
        web.scrollView.showsHorizontalScrollIndicator = false
        web.scrollView.showsVerticalScrollIndicator = false
        return web
    }()
    
    var messageHandler: DPCCHandler = {
        let handler = DPCCHandler.init()
        return handler
    }()
    
    var dpccLoadingView: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let view = UIActivityIndicatorView(activityIndicatorStyle: .large)
            return view
        } else {
            let view = UIActivityIndicatorView(frame: CGRect(origin: .zero, size: CGSize(width: 50, height: 50)))
            view.color = .gray
            return view
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(webView)
        view.addSubview(dpccLoadingView)
        dpccLoadingView.center = view.center
        dpccLoadingView.startAnimating()
        webView.configuration.userContentController.add(messageHandler, name: DPCCBridgeKey)
        messageHandler.commonDelegate = self
        webView.navigationDelegate = self
    }

}

extension DPCCBaseController: DPCCCommonDelegate {
    
    func sendAccountInfo(_ callBack: String?) {
        if let temp = callBack {
            var param = [String: String]()
            param["account"] = UserCookies.shared.account
            param["name"] = UserCookies.shared.name
            param["customerName"] = UserCookies.shared.customerName
            param["password"] = UserCookies.shared.password
            param["access_token"] = UserCookies.shared.accessToken
            let str = convertJsonFrom(dict: param as NSDictionary)
            let jsStr = temp + "(" + str + ")"
            webView.evaluateJavaScript(jsStr)
        }
    }
    
    func sendDeviceList(_ callBack: String?) {
        if let temp = callBack {

            var arr = [[String: AnyObject]]()
            
            if let sugarDevice = UserCookies.shared.sugarDevice {
                arr.append(sugarDevice)
            }
            if let pressureDevice = UserCookies.shared.pressureDevice {
                arr.append(pressureDevice)
            }
            if let heightDevice = UserCookies.shared.heightDevice {
                arr.append(heightDevice)
            }
            if let waistDevice = UserCookies.shared.waistDevice {
                arr.append(waistDevice)
            }
            let arrStr = convertJsonFrom(array: arr)
            let jsStr = temp + "(" + arrStr + ")"
            webView.evaluateJavaScript(jsStr)
        }
    }
    
    func sendBack() {
        navigationController?.popViewController(animated: true)
    }
    
}

extension DPCCBaseController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dpccLoadingView.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        dpccLoadingView.stopAnimating()
    }
}
