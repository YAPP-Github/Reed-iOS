// Copyright © 2025 Booket. All rights reserved

import Foundation

/// Google Analytics 스크린 이름을 관리하는 네임스페이스입니다.
/// enum으로 선언하여 인스턴스 생성을 방지합니다.
public enum GATracking {
    
    // MARK: - Onboarding & Auth
    public struct OnboardingAndAuth {
        private init() { }
        
        public static let splash = "splash"
        public static let onboarding = "onboarding"
        public static let selectMethod = "login_select_method"
        public static let termsAgreement = "login_terms_agreement"
    }
    
    // MARK: - Home & Library
    public struct HomeAndLibrary {
        private init() { }
        public static let homeMain = "home_main"
        public static let libraryMain = "library_main"
        public static let searchBook = "library_search_book"
        public static let bookDetail = "library_book_detail"
        public static let deleteBook = "library_book_delete"
        public static let deleteBookComplete = "library_book_delete_complete"
    }
    
    // MARK: - Search & Register
    public struct SearchAndRegister {
        private init() { }
        public static let start = "search_book_start"
        public static let result = "search_book_result"
        public static let noResult = "search_book_noresult"
        public static let selectOption = "register_book_option"
        public static let complete = "register_book_complete"
    }
    
    // MARK: - Record Flow
    public struct RecordFlow {
        private init() { }
        public static let start = "record_start"
        public static let inputSentence = "record_input_sentence"
        public static let ocrCamera = "record_OCR_camera"
        public static let ocrSentence = "record_OCR_sentence"
        public static let selectEmotion = "record_select_emotion"
        public static let inputOpinion = "record_input_opinion"
        public static let inputHelp = "record_input_help"
        public static let complete = "record_complete"
        public static let detail = "record_detail"
        public static let edit = "record_edit"
        public static let editSave = "record_edit_save"
        public static let delete = "record_delete"
        public static let deleteComplete = "record_delete_complete"
    }

    // MARK: - Record Card
    public struct RecordCard {
        private init() { }
        public static let create = "record_create_card"
        public static let main = "record_view_card"
        public static let save = "record_card_save"
        public static let share = "record_card_share"
    }
    
    // MARK: - Settings
    public struct Settings {
        private init() { }
        public static let main = "settings_main"
        public static let withdrawalWarning = "settings_withdrawal_warning"
        public static let withdrawalComplete = "settings_withdrawal_complete"
        public static let logoutComplete = "settings_logout_complete"
    }
    
    // MARK: - Error
    public struct Error {
        private init() { }
        public static let network = "error_network"
        public static let login = "error_login"
        public static let saveRecord = "error_record_save"
        public static let registerBook = "error_register_book"
        public static let search = "error_search"
        public static let searchLoading = "error_search_loading"
    }
}
