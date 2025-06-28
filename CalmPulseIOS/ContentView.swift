import SwiftUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePickerView
        init(_ parent: ImagePickerView) { self.parent = parent }
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
                // 워치로 전송
                PhoneSessionManager.shared.sendImageToWatch(image: image)
            }
            picker.dismiss(animated: true)
        }
    }
}

struct ContentView: View {
    @State private var showPicker = false
    @State private var selectedImage: UIImage?

    var body: some View {
        VStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            Button("사진 선택 및 워치로 전송") {
                showPicker = true
            }
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(selectedImage: $selectedImage)
        }
        .onAppear {
            _ = PhoneSessionManager.shared // 세션 활성화
        }
    }
} 