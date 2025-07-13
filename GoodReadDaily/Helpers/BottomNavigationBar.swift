//
//  BottomNavigationBar.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/10/25.
//

import UIKit

class BottomNavigationBar: UIView {
    // Closures for button actions
    var onMainTapped: (() -> Void)?
    var onResumeReadingTapped: (() -> Void)?
    var onSettingsTapped: (() -> Void)?
    
    private let mainButton = UIButton(type: .system)
    private let resumeReadingButton = UIButton(type: .system)
    private let settingsButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: -2)
        layer.shadowRadius = 4
        
        // Main Button
        mainButton.setImage(UIImage(systemName: "house.fill"), for: .normal)
        mainButton.tintColor = .systemGray
        mainButton.addTarget(self, action: #selector(mainTapped), for: .touchUpInside)
        
        // Resume Reading Button
        resumeReadingButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        resumeReadingButton.tintColor = .systemBrown
        resumeReadingButton.addTarget(self, action: #selector(resumeReadingTapped), for: .touchUpInside)
        
        // Settings Button
        settingsButton.setImage(UIImage(systemName: "gearshape.fill"), for: .normal)
        settingsButton.tintColor = .systemGray
        settingsButton.addTarget(self, action: #selector(settingsTapped), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [mainButton, resumeReadingButton, settingsButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
    }
    
    func updateMainButtonColor(_ isMainScreenActive: Bool) {
        let mainColor = UIColor(red: 89/255, green: 101/255, blue: 123/255, alpha: 1.0)
        mainButton.tintColor = isMainScreenActive ? mainColor : .systemGray
    }
    
    func updateResumeReadingButton(isEnabled: Bool) {
        resumeReadingButton.isEnabled = isEnabled
        resumeReadingButton.tintColor = isEnabled ? .systemBrown : .systemGray
    }
    
    func updateSettingsButtonColor(_ isSettingsScreenActive: Bool) {
        let mainColor = UIColor(red: 89/255, green: 101/255, blue: 123/255, alpha: 1.0)
        settingsButton.tintColor = isSettingsScreenActive ? mainColor : .systemGray
    }
    
    @objc private func mainTapped() {
        onMainTapped?()
    }
    
    @objc private func resumeReadingTapped() {
        onResumeReadingTapped?()
    }
    
    @objc private func settingsTapped() {
        onSettingsTapped?()
    }
}
