//
//  SubscriptionView.swift
//  Goal
//
//  Created by hashimo ryoya on 2023/10/22.
//

import SwiftUI
import StoreKit

enum SubscribeError: LocalizedError {
    case userCancelled // ユーザーによって購入がキャンセルされた
    case pending // クレジットカードが未設定などの理由で購入が保留された
    case productUnavailable // 指定した商品が無効
    case purchaseNotAllowed // OSの支払い機能が無効化されている
    case failedVerification // トランザクションデータの署名が不正
    case otherError // その他のエラー
}

class SubscriptionViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var isPrivilegeEnabled: Bool = false

    let productIdList = [
        "goalapp",
    ]

    func loadProducts() async {
        do {
            let products = try await Product.products(for: productIdList)
            DispatchQueue.main.async {
                self.products = products
                print("self.products")
                print(self.products)
            }
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
    func enablePrivilege(productId: String) {
        DispatchQueue.main.async {
            self.isPrivilegeEnabled = true
            print("self.isPrivilegeEnabled")
            print(self.isPrivilegeEnabled)
        }
    }

    func disablePrivilege() {
        DispatchQueue.main.async {
            self.isPrivilegeEnabled = false
            print("self.isPrivilegeEnabled")
            print(self.isPrivilegeEnabled)
        }
    }
    
    func purchaseProduct(_ product: Product) async throws {
        do {
            let transaction = try await purchase(product: product)
            print("購入が完了しました: \(transaction)")
        } catch {
            print("購入中にエラーが発生しました: \(error)")
        }
    }
}

private func getErrorMessage(error: Error) -> String {
    switch error {
    case SubscribeError.userCancelled:
        print("ユーザーによって購入がキャンセルされました")
        return "ユーザーによって購入がキャンセルされました"
    case SubscribeError.pending:
        print("購入が保留されています")
        return "購入が保留されています"
    case SubscribeError.productUnavailable:
        print("指定した商品が無効です")
        return "指定した商品が無効です"
    case SubscribeError.purchaseNotAllowed:
        print("OSの支払い機能が無効化されています")
        return "OSの支払い機能が無効化されています"
    case SubscribeError.failedVerification:
        return "トランザクションデータの署名が不正です"
        print("トランザクションデータの署名が不正です")
    default:
        print("不明なエラーが発生しました")
        return "不明なエラーが発生しました"
    }
}


class ProductCell: UITableViewCell {
    @IBOutlet weak var displayNameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var displayPriceLabel: UILabel!
    @IBOutlet weak var periodLabel: UILabel!

    // このプロパティに取得したProductインスタンスをセットする
    var product: Product? {
        didSet {
            print("ProductCell")
            displayNameLabel.text = product?.displayName
            descriptionLabel.text = product?.description
            displayPriceLabel.text = product?.displayPrice
            periodLabel.text = ""
            if let period = product?.subscription?.subscriptionPeriod {
                periodLabel.text = "\(period.value) \(period.unit)"
            }
        }
    }
}

func updateSubscriptionStatus() async {
    var validSubscription: StoreKit.Transaction?
    print("updateSubscriptionStatus1")
    for await verificationResult in Transaction.currentEntitlements {
        print("updateSubscriptionStatus2")
        if case .verified(let transaction) = verificationResult,
           transaction.productType == .autoRenewable && !transaction.isUpgraded {
            print("updateSubscriptionStatus3")
            validSubscription = transaction
        }
    }

//    if let productId = validSubscription?.productID {
//        // 特典を付与
//        enablePrivilege(productId: productId)
//    } else {
//        // 特典を削除
//        disablePrivilege()
//    }
}


func purchase(product: Product) async throws -> StoreKit.Transaction  {
    print("purchase1")
    // Product.PurchaseResultの取得
    let purchaseResult: Product.PurchaseResult
    do {
        print("purchase2")
        purchaseResult = try await product.purchase()
    } catch Product.PurchaseError.productUnavailable {
        print("purchase3")
        throw SubscribeError.productUnavailable
    } catch Product.PurchaseError.purchaseNotAllowed {
        print("purchase4")
        throw SubscribeError.purchaseNotAllowed
    } catch {
        print("purchase5")
        throw SubscribeError.otherError
    }

    // VerificationResultの取得
    let verificationResult: VerificationResult<StoreKit.Transaction>
    switch purchaseResult {
    case .success(let result):
        print("purchaseResult1")
        verificationResult = result
    case .userCancelled:
        print("purchaseResult2")
        throw SubscribeError.userCancelled
    case .pending:
        print("purchaseResult3")
        throw SubscribeError.pending
    @unknown default:
        print("purchaseResult4")
        throw SubscribeError.otherError
    }

    // Transactionの取得
    switch verificationResult {
    case .verified(let transaction):
        print("verificationResult1")
        return transaction
    case .unverified:
        print("verificationResult2")
        throw SubscribeError.failedVerification
    }
}

func observeTransactionUpdates() {
    print("observeTransactionUpdates1")
    Task(priority: .background) {
        print("observeTransactionUpdates2")
        for await verificationResult in Transaction.updates {
            print("observeTransactionUpdates3")
            guard case .verified(let transaction) = verificationResult else {
                print("observeTransactionUpdates4")
                continue
            }

//            if transaction.revocationDate != nil {
//                // 払い戻しされてるので特典削除
//                disablePrivilege()
//            } else if let expirationDate = transaction.expirationDate,
//                      Date() < expirationDate // 有効期限内
//                      && !transaction.isUpgraded // アップグレードされていない
//            {
//                // 有効なサブスクリプションなのでproductIdに対応した特典を有効にする
//                enablePrivilege(productId: transaction.productID)
//            }

            await transaction.finish()
        }
    }
}


struct SubscriptionView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    
    var body: some View {
        VStack {
            List(viewModel.products, id: \.id) { product in
                    Text("特典内容：広告を非表示にする")
                    Text("金額：100円")
                    Text("期間：1ヶ月")
                HStack{
                    Spacer()
                    Button(action: {
                        Task {
                            do {
                                try await viewModel.purchaseProduct(product)
                            } catch {
                                // ここでエラー処理を行います。
                                print("購入処理中にエラーが発生しました: \(error)")
                            }
                        }
                    }) {
//                        VStack(alignment: .leading) {
//                            Text(product.displayName)
//                                .font(.headline)
//                            Text(product.description)
//                                .font(.subheadline)
//                            Text(product.displayPrice)
//                                .font(.subheadline)
//                        }
                        Text("サブスクリプション登録")
                    }
                }
                Button(action: {
                    Task {
                        do {
//                            try await viewModel.purchaseProduct(product)
                            try await AppStore.sync()
                            try await viewModel.purchaseProduct(product)
                        } catch {
                            // ここでエラー処理を行います。
                            print("購入処理中にエラーが発生しました: \(error)")
                        }
                    }
                }) {
                    Text("購入の復元")
                }
            

//                Text(viewModel.isPrivilegeEnabled ? "特典が有効です" : "特典が無効です")
//                    .padding()
//                    .background(Color.gray.opacity(0.8))
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
            }
            .onAppear {
                Task {
                    await viewModel.loadProducts()
                }
            }
        }
    }
}


struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
    }
}
