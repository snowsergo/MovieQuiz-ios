import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClien
//    private let networkClient = NetworkClient()
    private let networkClient: NetworkRouting

    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - URL
//    k_pz49kj0s мой ключ k_xaempgf8
//    k_kiwxbi4y общий ключ яндекса
    private var mostPopularMoviesUrl: URL {
         guard let url = URL(string: "https://imdb-api.com/en/API/MostPopularMovies/k_xaempgf8") else {
             preconditionFailure("Unable to construct mostPopularMoviesUrl")
         }
         return url
     }
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: mostPopularMoviesUrl) { result in switch result {
        case .failure(let error):
            handler(.failure(error))
        case .success(let data):
            if let movies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) {
                handler(.success(movies))
            } else {
                return
            }}
        }
    }
    }
