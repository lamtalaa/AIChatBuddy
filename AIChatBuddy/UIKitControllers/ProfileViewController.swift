//
//  ProfileViewController.swift
//  AIChatBuddy
//
//  Created by Yassine Lamtalaa on 6/13/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileViewController: UIViewController {

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "mainScreenArt"))
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let nameTextField = ProfileViewController.createTextField(placeholder: "Name")
    private let ageTextField = ProfileViewController.createTextField(placeholder: "Age")
    private let genderTextField = ProfileViewController.createTextField(placeholder: "Gender")
    private let occupationTextField = ProfileViewController.createTextField(placeholder: "Occupation")
    private let locationTextField = ProfileViewController.createTextField(placeholder: "Location")
    
    private let bioTextView: UITextView = {
        let textView = UITextView()
        textView.layer.cornerRadius = 10
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Placeholder text setup
        textView.text = "Bio"
        textView.textColor = UIColor.black.withAlphaComponent(0.6)
        
        return textView
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 20)
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Picker Data
    private let ageOptions: [String] = Array(13...99).map { "\($0)" }
    private let genderOptions: [String] = ["Male", "Female", "Other"]
    
    // Pickers
    private let agePicker = UIPickerView()
    private let genderPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Profile"
        view.backgroundColor = .clear
        
        setupBackground()
        setupTranslucentViews()
        setupLayout()
        setupBioTextViewPlaceholder()
        setupPickers()
        loadUserProfile()
    }
    
    private func setupBackground() {
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func getImage() -> UIImage {
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        UIColor.clear.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return transparentImage
    }
    
    func setupTranslucentViews() {
        let toolbar = self.navigationController?.toolbar
        let navigationBar = self.navigationController?.navigationBar
        
        toolbar?.setBackgroundImage(getImage(), forToolbarPosition: .any, barMetrics: .default)
        navigationBar?.setBackgroundImage(getImage(), for: .default)
    }
    
    private static func createTextField(placeholder: String, keyboardType: UIKeyboardType = .default) -> UITextField {
        let tf = UITextField()
        tf.placeholder = placeholder
        tf.borderStyle = .roundedRect
        tf.keyboardType = keyboardType
        tf.backgroundColor = .clear
        tf.textColor = .black
        tf.layer.borderWidth = 1
        tf.layer.borderColor = UIColor.black.withAlphaComponent(0.5).cgColor
        tf.layer.cornerRadius = 8
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }
    
    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.keyboardDismissMode = .interactive
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        let stack = UIStackView(arrangedSubviews: [
            nameTextField,
            ageTextField,
            genderTextField,
            occupationTextField,
            locationTextField,
            bioTextView,
            saveButton
        ])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            bioTextView.heightAnchor.constraint(equalToConstant: 120),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
    }
    
    private func setupBioTextViewPlaceholder() {
        bioTextView.delegate = self
    }
    
    private func setupPickers() {
        agePicker.delegate = self
        agePicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        ageTextField.inputView = agePicker
        genderTextField.inputView = genderPicker
        
        // Add toolbar with Done button for pickers
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done,
                                         target: self,
                                         action: #selector(dismissPicker))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                        target: nil,
                                        action: nil)
        toolbar.setItems([flexSpace, doneButton], animated: false)
        
        ageTextField.inputAccessoryView = toolbar
        genderTextField.inputAccessoryView = toolbar
    }
    
    private func loadUserProfile() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let docRef = Firestore.firestore().collection("users").document(uid)
        docRef.getDocument { document, error in
            if let error = error {
                print("❌ Error loading profile: \(error.localizedDescription)")
                return
            }

            guard let data = document?.data() else {
                print("ℹ️ No profile data found")
                return
            }

            self.nameTextField.text = data["name"] as? String
            self.ageTextField.text = data["age"] as? String
            self.genderTextField.text = data["gender"] as? String
            self.occupationTextField.text = data["occupation"] as? String
            self.locationTextField.text = data["location"] as? String

            if let bio = data["bio"] as? String, !bio.isEmpty {
                self.bioTextView.text = bio
                self.bioTextView.textColor = .black
            } else {
                self.bioTextView.text = "Bio"
                self.bioTextView.textColor = UIColor.black.withAlphaComponent(0.6)
            }
        }
    }
    
    @objc private func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc private func saveProfile() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }

        let userData: [String: Any] = [
            "name": nameTextField.text ?? "",
            "age": ageTextField.text ?? "",
            "gender": genderTextField.text ?? "",
            "occupation": occupationTextField.text ?? "",
            "location": locationTextField.text ?? "",
            "bio": (bioTextView.textColor == UIColor.black.withAlphaComponent(0.6)) ? "" : bioTextView.text ?? "",
            "timestamp": FieldValue.serverTimestamp()
        ]

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .setData(userData, merge: true) { error in
                if let error = error {
                    print("❌ Error saving profile: \(error.localizedDescription)")
                    self.showAlert(title: "Error", message: "Failed to save profile.")
                } else {
                    print("✅ Profile saved for user: \(uid)")
                    self.showAlert(title: "Saved", message: "Your profile has been updated successfully.")
                }
            }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
    }
}

// MARK: - UITextViewDelegate for bio placeholder
extension ProfileViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == bioTextView && textView.textColor == UIColor.black.withAlphaComponent(0.6) {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == bioTextView && textView.text.isEmpty {
            textView.text = "Bio"
            textView.textColor = UIColor.black.withAlphaComponent(0.6)
        }
    }
}

// MARK: - UIPickerViewDelegate & UIPickerViewDataSource
extension ProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == agePicker {
            return ageOptions.count
        } else if pickerView == genderPicker {
            return genderOptions.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == agePicker {
            return ageOptions[row]
        } else if pickerView == genderPicker {
            return genderOptions[row]
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == agePicker {
            ageTextField.text = ageOptions[row]
        } else if pickerView == genderPicker {
            genderTextField.text = genderOptions[row]
        }
    }
}
