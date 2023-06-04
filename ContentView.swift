import SwiftUI
import PhotosUI
import MobileCoreServices

struct ContentView: View {

    @State private var selectedTab = 0
    
    @State private var message = ""
    @State private var show = false
    
    @State private var selectedImage: UIImage?
    @State private var isShowingPicker = false
    
    @State private var selectedFileURL: URL?
    @State private var isShowingFile = false
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            NavigationStack {
                VStack(alignment: .leading) {
                    Spacer()
                    ZStack {
                        TextField("Mensaje", text: $message)
                            .frame(maxWidth: .infinity)
                            .padding(13)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                        HStack {
                            Spacer()
                            Button(action: {
                                message = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color.gray)
                                    .opacity(message.isEmpty ? 0 : 1)
                                    .padding(.trailing, 8)
                            }
                            .padding(.trailing, 8)
                            .opacity(message.isEmpty ? 0 : 1)
                        }
                    }
    
                    Label("Enviar", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .font(.headline)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 10)
                        .onTapGesture {
                            sendMessage()
                        }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Mensaje")
            }
            .tabItem {
                Label("Mensaje", systemImage: "bubble.left")
            }
            .tag(0)
            
            NavigationStack {
                VStack {
                    ZStack {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 200, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                .frame(width: 200, height: 220)
                                .background(Color(.systemBackground))
                                .overlay(
                                    Rectangle()
                                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                        .foregroundColor(Color.clear)
                                )
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .frame(width: 200, height: 220)
                    
                    Label("Enviar", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: 200)
                        .padding(12)
                        .font(.headline)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 20)
                        .onTapGesture {
                            sendImage()
                        }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    isShowingPicker = true
                }
                .sheet(isPresented: $isShowingPicker) {
                    PhotoPicker(selectedImage: $selectedImage)
                }
                .padding()
                .navigationTitle("Imagen")
            }
            .tabItem {
                Label("Imagen", systemImage: "photo")
            }
            .tag(1)
            
            NavigationStack {
                VStack {
                    Spacer()
                    
                    Label("Archivo", systemImage: "doc")
                        .frame(maxWidth: .infinity)
                        .padding(13)
                        .foregroundColor(Color.accentColor)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .fileImporter(isPresented: $isShowingFile, allowedContentTypes: [.item], onCompletion: handleFileSelection)
                        .onTapGesture {
                            isShowingFile = true
                        }
                    
                    Label("Enviar", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .font(.headline)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.vertical, 5)
                        .onTapGesture {
                            sendFile()
                        }
                    
                    Spacer()
                }
                .padding()
                .navigationTitle("Archivo")
            }
            .tabItem {
                Label("Archivo", systemImage: "doc")
            }
            .tag(2)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func sendMessage() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    private func sendImage() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController,
              let image = selectedImage else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }

    private func handleFileSelection(result: Result<URL, Error>) {
            guard case let .success(fileURL) = result else { return }
            selectedFileURL = fileURL
        }

    private func sendFile() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let rootViewController = windowScene.windows.first?.rootViewController,
                let fileURL = selectedFileURL else {
            return
        }

        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        let parent: PhotoPicker
        
        init(parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true, completion: nil)
            
            guard let result = results.first else {
                return
            }
            
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                if let image = image as? UIImage {
                    DispatchQueue.main.async {
                        self?.parent.selectedImage = image
                    }
                }
            }
        }
    }
}

