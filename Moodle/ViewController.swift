    //
    //  ViewController.swift
    //  Moodle
    //
    //  Created by Marco Tini on 14.12.2021.
    //  Copyright © 2021 Marco Tini. All rights reserved.
    //

    import UIKit
    import WebKit
    
    class ViewController: UIViewController {
        
        private lazy var url = URL(string: "http://*.*.com/my/index.php")!
        private weak var webView: WKWebView?
        
        func initWebView(configuration: WKWebViewConfiguration) {
            if webView != nil { return }
            let webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
            webView.navigationDelegate = self
            webView.uiDelegate = self
            view.addSubview(webView)
            self.webView = webView
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if webView == nil { initWebView(configuration: WKWebViewConfiguration()) }
            webView?.load(url: url)
        }
    }
    
    extension ViewController: WKNavigationDelegate {
        
        func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            if let url = webView.url {
                webView.getCookies(for: url.host) { data in
                    print("=========================================")
                    print("\(url.absoluteString)")
                    print(data)
                }
            }
        }
    }
    
    extension ViewController: WKUIDelegate {
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            // push new screen to the navigation controller when need to open url in another "tab"
            if let url = navigationAction.request.url, navigationAction.targetFrame == nil {
                let viewController = ViewController()
                viewController.initWebView(configuration: configuration)
                viewController.url = url
                DispatchQueue.main.async { [weak self] in
                    self?.navigationController?.pushViewController(viewController, animated: true)
                }
                return viewController.webView
            }
            return nil
        }
    }
    
    extension WKWebView {
        
        func load(urlString: String) {
            if let url = URL(string: urlString) { load(url: url) }
        }
        
        func load(url: URL) { load(URLRequest(url: url)) }
    }

    extension WKWebView {
        
        private var httpCookieStore: WKHTTPCookieStore  { return WKWebsiteDataStore.default().httpCookieStore }
        
        func getCookies(for domain: String? = nil, completion: @escaping ([String : Any])->())  {
            var cookieDict = [String : AnyObject]()
            httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    if let domain = domain {
                        if cookie.domain.contains(domain) {
                            cookieDict[cookie.name] = cookie.properties as AnyObject?
                        }
                    } else {
                        cookieDict[cookie.name] = cookie.properties as AnyObject?
                    }
                }
                completion(cookieDict)
            }
        }
    }
