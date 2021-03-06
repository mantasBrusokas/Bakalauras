//
//  DatabaseManager.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-03-29.
//

import Foundation
import FirebaseDatabase
import CoreLocation
import MessageKit

final class DatabaseManager{
    
    static let shared = DatabaseManager()
        
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

// Account Manager!

    extension DatabaseManager {
        
        public func userExists(with email: String,
                               completion: @escaping ((Bool) -> Void)) {
            
            var safeEmail = email.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            
            database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.exists() else {
                    completion(false)
                    return
                }
                completion(true)
            })
        }
        
        public func getCurrentUser(currentUserEmail: String, completion: @escaping (Result<AppUser, Error>) -> Void ) {
            database.child("users").observe(.value, with: {snapshot in
                guard let value = snapshot.value as? [[String: Any]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                let users: [AppUser] = value.compactMap({ dictionary in
                    guard let brand = dictionary["brand"] as? String,
                          let name = dictionary["name"] as? String,
                          let city = dictionary["city"] as? String,
                          let email = dictionary["email"] as? String,
                          let distance = dictionary["distance"] as? String,
                          let gender = dictionary["gender"] as? String,
                          currentUserEmail == email,
                          let born = dictionary["born"] as? String else{
                        return nil
                    }
                    return AppUser(firstName: name, lastName: "", emailAddress: email, brand: brand, bornDate: born, city: city, distance: distance, gender: gender)
                })
                guard let currentUser = users.first else {
                    print("User info not valid")
                    return
                    
                }
                completion(.success(currentUser))
            })
        }
        
        /// update user
        public func updateUser(safeEmail: String, newUserInfo: AppUser, completion: @escaping (Bool) -> Void) {
            var usersCollection = [[String: Any?]] ()
            database.child(safeEmail).updateChildValues([
                "born": newUserInfo.bornDate,
                "brand": newUserInfo.brand,
                "city": newUserInfo.city,
                "gender": newUserInfo.gender,
                "distance": newUserInfo.distance,
                
            ], withCompletionBlock: { error, _ in
                guard error == nil else {
                    print("failed to write to db")
                    completion(false)
                    return
                }
                self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    guard let value = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    let users: [AppUser] = value.compactMap({ dictionary in
                        if let email = dictionary["email"] as? String,
                           safeEmail == email {
                            print("Ateina 1")
                            
                            let newElement = [
                                "name": dictionary["name"],
                                "email": newUserInfo.safeEmail,
                                "born": newUserInfo.bornDate,
                                "brand": newUserInfo.brand,
                                "city": newUserInfo.city,
                                "gender": newUserInfo.gender,
                                "distance": newUserInfo.distance,
                            ]
                            usersCollection.append(newElement)
                        } else {
                            print("Ateina 2")
                            let newElement2 = [
                                "name": dictionary["name"] as! String,
                                "email": dictionary["email"] as! String,
                                "born": dictionary["born"] as! String ,
                                "brand": dictionary["brand"] as! String,
                                "city": dictionary["city"] as! String,
                                "gender": dictionary["gender"] as! String,
                                "distance": dictionary["distance"] as! String,
                            ]
                            usersCollection.append(newElement2)
                        }
                        return AppUser(firstName: newUserInfo.firstName, lastName:  newUserInfo.firstName, emailAddress: newUserInfo.firstName, brand: newUserInfo.firstName, bornDate: newUserInfo.firstName, city: newUserInfo.firstName, distance: newUserInfo.firstName, gender: newUserInfo.firstName)
                    })
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                    })
                    
                    completion(true)
                })
            })
            
        }
        
    /// Inserts  new user to database
        public func insertUser(with user: AppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "name": user.firstName + " " + user.lastName,
            "born": user.bornDate,
            "brand": user.brand,
            "city": user.city,
            "gender": user.gender,
            "distance": user.distance,
            
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("failed to write to db")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    // append users dictionary
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail,
                        "born": user.bornDate,
                        "brand": user.brand,
                        "city": user.city,
                        "gender": user.gender,
                        "distance": user.distance,
                    ]
                    usersCollection.append(newElement)
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })

                } else {
                    // create users dictionery
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail,
                            "born": user.bornDate,
                            "brand": user.brand,
                            "city": user.city,
                            "gender": user.gender,
                            "distance": user.distance,
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
            })
        })
    }
        public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void){
            database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                guard let value =  snapshot.value as? [[String: String]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(value))
            })
        }
        
        public enum DatabaseError: Error {
            case failedToFetch
        }
}

extension DatabaseManager {
    
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
            
        })
    }
}



// MARK: - Sending messages / conversations
extension DatabaseManager {
    /// Create a new conversation
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
        let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dataFormatter.string(from: messageDate)
            var message = ""
            
            switch firstMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": otherUserEmail,
                "name" : name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_email": safeEmail,
                "name" : currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            // Update recipient conversation
            
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversations)
                } else {
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            // Update current user conversation
            if var conversations = userNode["conversations"] as? [[String: Any]] {
            // conversations array exists for current user
            // you should append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
            else {
                // conversation array not exist
                userNode["conversations"] = [
                newConversationData
             
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name,
                                                     conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
            
            
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
      
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dataFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "isRead": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding conversation: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Fetches and returns all convertanions for the user with passed email
    public func getAllConvesations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void ) {
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        read: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
            
        })
    }
    
    /// Fetches and returns all convertanions for the user with passed email
    public func checkConvesation(for email: String, checkUserEmail: String, completion: @escaping (Result<[Conversation], Error>) -> Void ) {
        database.child("\(email)/conversations").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      otherUserEmail == checkUserEmail,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    print("Nulas")
                    return nil
                }
                print(otherUserEmail)
                print(checkUserEmail)
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        read: isRead)
                return Conversation(id: conversationId, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
            
        })
    }
    
    /// Get all messages for given convo
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }

            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dataFormatter.date(from: dateString)
                else {
                    return nil
                }
                
                let sender = Sender(photoURL: "",
                                    senderId: senderEmail,
                                    displayName: name)

                print("Returned messages:\(content)")
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })

            
            completion(.success(messages))
            
        })
        
    }
    
    /// Sends a message with target convesation adnd message
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        // add new message to messages
        // update sender latest message
        // update recipient latest message
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dataFormatter.string(from: messageDate)
            
           
            var message = ""
            switch newMessage.kind {
            
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }
            
            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "isRead": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    // atnaujinam latest Conversation, kad rodytu conversations vaizde
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                            
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        // Atnaujina zinute ja gaunanciam useriui
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            // atnaujinam latest Conversation, kad rodytu conversations vaizde
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var targetConversation: [String: Any]?
                            
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                                    
                            }
                            
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
                
            }
        })
    }
    
    public func conversationExists(with targetRecipientEmail: String, completion: @escaping (Result<String, Error>) -> Void) {
        let safeRecipientEmail = DatabaseManager.safeEmail(emailAddress: targetRecipientEmail)
        guard let senderEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeSenderEmail = DatabaseManager.safeEmail(emailAddress: senderEmail)
        
        
    }
    

}

extension DatabaseManager {
    
    public func createNewPost(post: Post, completion: @escaping (Bool) -> Void) {
        let locationMap = "\(post.location.location.coordinate.longitude),\(post.location.location.coordinate.latitude)"
        
        self.database.child("posts").observeSingleEvent(of: .value, with: { snapshot in
            if var postsCollection = snapshot.value as? [[String: Any]] {
                // append posts dictionary
                let newElement: [String: Any] = [
                    "id": post.id,
                    "name": post.authorName,
                    "email": post.email,
                    "date": post.date,
                    "text": post.text,
                    "isRead": post.read,
                    "runningDate": post.runningDate,
                    "location": locationMap,
                ]
                
                postsCollection.insert(newElement, at: 0)
                self.database.child("posts").setValue(postsCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })

            } else {
                // create posts dictionery
                let newCollection: [[String: Any]] = [
                    [
                        "id": post.id,
                        "name": post.authorName,
                        "email": post.email,
                        "date": post.date,
                        "text": post.text,
                        "isRead": post.read,   
                        "runningDate": post.runningDate,
                        "location": locationMap,
                    ]
                ]
                self.database.child("posts").setValue(newCollection, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    
                    completion(true)
                })
            }
        })
    }
    
    /// Fetches and returns all posts
    public func getAllPosts(completion: @escaping (Result<[Post], Error>) -> Void ) {
        database.child("posts").observe(.value, with: {snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let posts: [Post] = value.compactMap({ dictionary in
                guard let postId = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let email = dictionary["email"] as? String,
                      let text = dictionary["text"] as? String,
                      let date = dictionary["date"] as? String,
                      let isRead = dictionary["isRead"] as? Bool,
                      let runningDate = dictionary["runningDate"] as? String,
                      let locationFromDB = dictionary["location"] as? String else {
                    return nil
                }
                let locationComponents = locationFromDB.components(separatedBy: ",")
                guard let longitude = Double(locationComponents[0]),
                    let latitude = Double(locationComponents[1]) else {
                    return nil
                }
                let location = Location(location: CLLocation(latitude: latitude, longitude: longitude),
                                        size: .zero)
                return Post(id: postId, authorName: name, email: email, date: date, text: text, read: isRead, runningDate: runningDate, location: location)
            })
            completion(.success(posts))
            
        })
    }
    
    public func deletePost(postId: String, completion: @escaping (Bool) -> Void) {
        
        print("Deleting conversation with id: \(postId)")

        let ref = database.child("posts")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var posts = snapshot.value as? [[String: Any]] {
                var positionToRemove = 0
                for post in posts {
                    if let id = post["id"] as? String,
                        id == postId {
                        print("found post to delete")
                        break
                    }
                    positionToRemove += 1
                }

                posts.remove(at: positionToRemove)
                ref.setValue(posts, withCompletionBlock: { error, _  in
                    guard error == nil else {
                        completion(false)
                        print("faield to write new posts array")
                        return
                    }
                    print("deleted post")
                    completion(true)
                })
            }
        }
    }
    
}

    struct AppUser {
        let firstName: String
        let lastName: String
        let emailAddress: String
        let brand: String
        let bornDate: String
        let city: String
        let distance: String
        let gender: String
        
        var safeEmail: String {
            var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
            safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
            return safeEmail
        }
        
        var profilePictureFileName: String {
            return "\(safeEmail)_profile_picture.png"
        }
        
    }
