import Foundation

struct User: Codable {
    let id: String
    let email: String
    let username: String
    let profile: Profile
    let apiKey: String


    func toCSV() -> String {
        return "\(id),\(email),\(username),\(profile.company),\(profile.dob),\(profile.address),\(profile.location.lat),\(profile.location.long),\(profile.about),\(apiKey)\n"
}
}

struct Profile: Codable {
    let company: String
    let dob: String
    let address: String
    let location: Location
    let about: String
}

struct Location: Codable {
    let lat: Double
    let long: Double
}

let jsonString = """
[
  {
    "id": "65673faddadafc1b49f11c98",
    "email": "@surelogic.delivery",
    "username": "undefined89",
    "profile": {
      "company": "Surelogic",
      "dob": "1989-12-22",
      "address": "7 Gaylord Drive, Tecolotito, Massachusetts",
      "location": {
        "lat": -22.275091,
        "long": 42.541518
      },
      "about": "Consequat ut ad eu officia id irure proident Lorem. Est ad tempor aute eu consequat."
    },
    "apiKey": "bc481472-7235-4498-af8f-fe9491ec2fce"
  },
  {
    "id": "65673fade11fe5768320166e",
    "email": "@zepitope.design",
    "username": "undefined92",
    "profile": {
      "company": "Zepitope",
      "dob": "1992-10-18",
      "address": "35 Scholes Street, Frystown, American Samoa",
      "location": {
        "lat": 57.265831,
        "long": 41.679563
      },
      "about": "Dolor cillum duis labore duis ea consequat non enim exercitation qui nulla ad Lorem quis. Commodo id do commodo consequat ex mollit consectetur exercitation ullamco elit quis sint."
    },
    "apiKey": "8dbcf051-2493-411b-a131-e3fefb2ecea9"
  }
]
"""

//let jsonData = jsonString.data(using: .utf8)!

do {


    if let fileURL = Bundle.main.url(forResource: "json1", withExtension: "json") {
        if let jsonData = try? Data(contentsOf: fileURL){
            let users = try JSONDecoder().decode([User].self, from: jsonData)
        
            var csvString = "id,email,username,company,dob,address,lat,long,about,apiKey\n"

            for user in users {
                csvString.append(user.toCSV())
            }       
    
            let csvURL = URL(fileURLWithPath: "/home/artemokky/io_swift/Sources/file.csv")
    
            try csvString.write(to: csvURL, atomically: true, encoding: .utf8)
        }
    }  // Read the contents of the file
}    
