//
//  FloatingActionButton.swift
//  GoodReadDaily
//
//  Created by Yaroslav Solovev on 7/9/25.
//

import UIKit

class FloatingActionButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }
    
    private func setupButton() {
        backgroundColor = .lightGray
        tintColor = .white
        setImage(UIImage(systemName: "plus"), for: .normal)
        layer.cornerRadius = 28
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 6
        layer.shadowOpacity = 0.3
        
        addTarget(self, action: #selector(animateTap), for: .touchUpInside)
    }
    
    @objc private func animateTap() {
        UIView.animate(withDuration: 0.1, animations: {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.transform = .identity
            }
        }
    }
}
