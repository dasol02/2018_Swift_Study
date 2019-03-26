import UIKit
import Alamofire


struct UserInfoKey {
    static let loginID = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

class UserInfoManager{
    
    // 로그인 유무
    var isLogin : Bool {
        
        if self.loginID == 0 || self.account == nil{
            return false
        }else{
            return true
        }
    }
    
    
    // 연산 프로퍼티 loginID 정의
    var loginID: Int {
        get {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginID)
        }
        set(v){
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.loginID)
            ud.synchronize()
        }
    }
    
    // 계정
    var account : String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set (v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    // 이름
    var name : String? {
        get {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set (v) {
            let ud = UserDefaults.standard
            ud.set(v, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    // 프로필 이미지
    var profile : UIImage? {
        get {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile){
                return UIImage(data: _profile)
            }else{
                return UIImage(named: "account.jpg")
            }
        }
        set (v) {
            if v != nil {
                let ud = UserDefaults.standard
                ud.set(v?.pngData(), forKey: UserInfoKey.profile)
                ud.synchronize()
            }
        }
    }
    
    // 로그인 시도
    func login(inputAccount: String, passwd: String, success: (() -> Void)? = nil, fail: ((String) -> Void)? = nil){
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = [
            "account": inputAccount,
            "passwd" : passwd
        ]
        
        
        let call = Alamofire.request(url, method: HTTPMethod.post, parameters: param, encoding: JSONEncoding.default)
        
        call.responseJSON{ res in
            
            guard let jsonObject = res.result.value as? NSDictionary else{
                fail?("잘못된 응답 형식입니다:\(res.result.value!)")
                return
            }
            
            let resultCode = jsonObject["result_code"] as! Int
            
            if resultCode == 0 {
                
                let user = jsonObject["user_info"] as! NSDictionary
                
                self.loginID = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                if let path = user["profile_path"] as? String {
                    if let imageData = try? Data(contentsOf: URL(string:path)!) {
                        self.profile = UIImage(data: imageData)
                    }
                    
                }
                
                success?()
                
            } else {
                let msg = (jsonObject["error_msg"] as? String ?? "로그인이 실패 했습니다.")
                fail?(msg)
            }
        }
        
        
    }

    // 로그아웃
    func logout() -> Bool {
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UserInfoKey.loginID)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.profile)
        ud.synchronize()
        return true
    }
}
