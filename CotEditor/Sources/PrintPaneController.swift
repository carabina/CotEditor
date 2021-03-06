/*
 
 PrintPaneController.swift
 
 CotEditor
 https://coteditor.com
 
 Created by 1024jp on 2014-04-18.
 
 ------------------------------------------------------------------------------
 
 © 2004-2007 nakamuxu
 © 2014-2016 1024jp
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
 */

import Cocoa

final class PrintPaneController: NSViewController {
    
    // MARK: Private Properties
    
    @IBOutlet private weak var fontField: NSTextField?
    @IBOutlet private weak var colorPopupButton: NSPopUpButton?
    
    
    
    // MARK:
    // MARK: Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    override var nibName: String? {
        
        return "PrintPane"
    }
    
    
    
    // MARK: View Controller Methods
    
    /// setup UI
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setupFontFamilyNameAndSize()
        self.setupColorMenu()
        
        // observe theme list update
        NotificationCenter.default.addObserver(self, selector: #selector(setupColorMenu), name: .ThemeListDidUpdate, object: nil)
    }
    
    
    
    // MARK: Action Messages
    
    /// show font panel
    @IBAction func showFonts(_ sender: Any?) {
        guard let font = NSFont(name: Defaults[.printFontName]!,
                                size: Defaults[.printFontSize]) else { return }
        
        self.view.window?.makeFirstResponder(self)
        NSFontManager.shared().setSelectedFont(font, isMultiple: false)
        NSFontManager.shared().orderFrontFontPanel(sender)
    }
    
    
    /// font in font panel did update
    @IBAction override func changeFont(_ sender: Any?) {
        
        guard let fontManager = sender as? NSFontManager else { return }
        
        let newFont = fontManager.convert(NSFont.systemFont(ofSize: 0))
        
        Defaults[.printFontName] = newFont.fontName
        Defaults[.printFontSize] = newFont.pointSize
        
        self.setupFontFamilyNameAndSize()
    }
    
    
    /// color setting did update
    @IBAction func changePrintTheme(_ sender: Any?) {
        
        guard let popup = sender as? NSPopUpButton else { return }
        
        let index = popup.indexOfSelectedItem
        let theme = (index > 2) ? popup.titleOfSelectedItem : nil  // do not set theme on `Black and White` and `same as document's setting`
        
        Defaults[.printTheme] = theme
        Defaults[.printColorIndex] = index
    }
    
    
    
    // MARK: Private Methods
    
    /// display font name and size in the font field
    private func setupFontFamilyNameAndSize() {
        
        let name = Defaults[.printFontName]!
        let size = Defaults[.printFontSize]
        
        guard let font = NSFont(name: name, size: size),
              let displayFont = NSFont(name: name, size: min(size, 13.0)),
              let fontField = self.fontField else { return }
        
        fontField.stringValue = font.displayName! + " " + String(format:"%g", size)
        fontField.font = displayFont
    }
    
    
    /// setup popup menu for color setting
    func setupColorMenu() {
        
        let index = Defaults[.printColorIndex]
        let themeName = Defaults[.printTheme]
        let themeNames = ThemeManager.shared.themeNames
        
        guard let popupButton = self.colorPopupButton else { return }
        
        popupButton.removeAllItems()
        
        // build popup button
        popupButton.addItem(withTitle: NSLocalizedString("Black and White", comment: ""))
        popupButton.addItem(withTitle: NSLocalizedString("Same as Document’s Setting", comment: ""))
        popupButton.menu?.addItem(NSMenuItem.separator())
        popupButton.addItem(withTitle: NSLocalizedString("Theme", comment: ""))
        for name in themeNames {
            popupButton.addItem(withTitle: name)
            popupButton.lastItem?.indentationLevel = 1
        }
        
        // select menu
        popupButton.selectItem(at: 0)  // black and white (default)
        if let themeName = themeName {
            if themeNames.contains(themeName) {
                popupButton.selectItem(withTitle: themeName)
            } else if index == 1 {
                popupButton.selectItem(at: 1)  // same as document
            }
        }
    }
    
}
