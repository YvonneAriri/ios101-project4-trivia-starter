//
//  TriviaQuestion.swift
//  Trivia
//
//  Created by Mari Batilando on 4/6/23.
//

import Foundation

struct TriviaAPIResponse: Decodable {
    let results: [TriviaQuestion]
}

struct TriviaQuestion: Decodable {
    let category: String
    let question: String
    let correctAnswer: String
    let incorrectAnswers: [String]

    private enum CodingKeys: String, CodingKey {
        case category = "category"
        case question = "question"
        case correctAnswer = "correct_answer"
        case incorrectAnswers = "incorrect_answers" 
    }
}

class TriviaService {
    static func fetchTriviaQuestions(completion: ((Result<[TriviaQuestion], Error>) -> Void)? = nil) {
        let url = URL(string: "https://opentdb.com/api.php?amount=20")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let error = NSError(domain: "HTTPError", code: statusCode, userInfo: nil)
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
                return
            }

            guard let data = data else {
                let error = NSError(domain: "NoDataError", code: -1, userInfo: nil)
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
                return
            }
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(TriviaAPIResponse.self, from: data)
                DispatchQueue.main.async {
                    completion?(.success(response.results))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
        task.resume()
    }
    
}
