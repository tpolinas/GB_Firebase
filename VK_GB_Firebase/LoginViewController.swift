import UIKit
import FirebaseAuth

final class LoginViewController: UIViewController {
    
    @IBOutlet var usernameTextField: UITextField! {
        didSet {
            usernameTextField.placeholder = NSLocalizedString(
                "Weather.Hello",
                comment: "Hello")
        }
    }
    
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var scrollView: UIScrollView!
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard
            let username = usernameTextField.text,
            let password = passwordTextField.text
        else { return }
        authBy(
            email: username,
            password: password)
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        guard
            let username = usernameTextField.text,
            let password = passwordTextField.text,
            !username.isEmpty,
            !password.isEmpty
        else {
            return presentAlert(message: "Invalid data")
        }
        
        Auth.auth().createUser(
            withEmail: username,
            password: password) { [weak self] resultAuth, errorAuth in
                guard let self = self else { return }
                if let error = errorAuth {
                    self.presentAlert(message: error.localizedDescription)
                } else {
                    self.authBy(
                        email: username,
                        password: password)
                }
            }
    }
    
    
    @IBAction func unwindToMain(unwindSegue: UIStoryboardSegue) {
        try? Auth.auth().signOut()
    }
    
    private var authNotification: AuthStateDidChangeListenerHandle?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView
            .addGestureRecognizer(
                UITapGestureRecognizer(
                    target: self,
                    action: #selector(hideKeyboard)))
    }
    
    deinit {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name("myNewNotification"),
            object: nil)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWasShown),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillBeHidden(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        navigationController?.navigationBar.isHidden = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(someMethod),
            name: NSNotification.Name("myNewNotification"),
            object: nil)
        
        self.authNotification = Auth.auth().addStateDidChangeListener({ auth, user in
            if user != nil {
                self.performSegue(withIdentifier: "goToMain", sender: nil)
                self.usernameTextField.text = nil
                self.passwordTextField.text = nil
            }
        })
    }
    
    @objc
    private func someMethod(notification: Notification) {
        let model = notification.userInfo?["someModel"]
        print(model)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
        navigationController?.navigationBar.isHidden = false
        guard let authNotification = authNotification else { return }
        Auth.auth().removeStateDidChangeListener(authNotification)
    }
    
    // MARK: - Actions
    @objc func keyboardWasShown(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let kbSize = (info.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue)
            .cgRectValue
            .size
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        UIView.animate(withDuration: 1) {
            self.scrollView.constraints
                .first(where: { $0.identifier == "keyboardShown" })?
                .priority = .required
            self.scrollView.constraints
                .first(where: { $0.identifier == "keyboardHide" })?
                .priority = .defaultHigh
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillBeHidden(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        UIView.animate(withDuration: 1) {
            self.scrollView.constraints
                .first(where: { $0.identifier == "keyboardShown" })?
                .priority = .defaultHigh
            self.scrollView.constraints
                .first(where: { $0.identifier == "keyboardHide" })?
                .priority = .required
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func hideKeyboard() {
        self.scrollView?.endEditing(true)
    }
    
    
    // MARK: - Private methods
    private func authBy(email: String, password: String) {
        Auth.auth().signIn(
            withEmail: email,
            password: password) { [weak self] authResult, authError in
                guard let self = self else { return }
                if let error = authError {
                    self.presentAlert(message: error.localizedDescription)
                }
            }
    }
    
    private func presentAlert(message: String = "Incorect username or password") {
        let alertController = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: "Close", style: .cancel)
        alertController.addAction(action)
        present(alertController,
                animated: true)
    }
    
    private func clearData() {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
}
