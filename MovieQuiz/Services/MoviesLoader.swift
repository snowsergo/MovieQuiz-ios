import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}

struct MoviesLoader: MoviesLoading {
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    init(networkClient: NetworkRouting = NetworkClient()) {
        self.networkClient = networkClient
    }
    // MARK: - URL
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
            do {
                let apiResponse = try JSONDecoder().decode(ApiErrorResponse.self, from: data)

                if !apiResponse.error.isEmpty {
                    DispatchQueue.main.async {
                        print("ERROR =", apiResponse.error)
                        handler(.failure(ApiError.genericError(message: apiResponse.error)))
                    }
                }
                else if let movies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) {
                    if movies.items.isEmpty {
                        handler(.failure(ApiError.genericError(message: "Список фильмов пуст")))
                    }
                    handler(.success(movies))
                } else {
                    return
                }
            }
            catch let err {
                DispatchQueue.main.async {
                    handler(.failure(err))
                }
            }
        }
        }
    }
}
