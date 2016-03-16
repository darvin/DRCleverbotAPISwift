// https://github.com/Quick/Quick

import Quick
import Nimble
import DRCleverbotAPISwift

class CleverBotSpec: QuickSpec {
    override func spec() {
        
        describe("clever bot") {
            it ("should be initialized and send first request") {
                waitUntil(timeout: 10) { done in

                    let cleverBot = DRCleverBot();
                    cleverBot.startSession({ () -> () in
                        cleverBot.ask("Hi!", completion: { (answer:String?) -> Void in
                            expect(answer).toNot(beNil())
                            expect(answer!.characters.count).to(beGreaterThan(1))
                            expect(answer!.characters.count).to(beLessThan(100))
                            done()
                        })
                    });
                }
            }
            
            
            it ("should do conversation") {
                waitUntil(timeout: 10) { done in
                    
                    let cleverBot = DRCleverBot();
                    cleverBot.startSession({ () -> () in
                        cleverBot.ask("Hi!", completion: { (answer:String?) -> Void in
                            print (" cleverbot => ", answer)
                            expect(answer).toNot(beNil())
                            expect(answer!.characters.count).to(beGreaterThan(1))
                            expect(answer!.characters.count).to(beLessThan(100))
                            cleverBot.ask("My name is Sergey!", completion: { (answer:String?) -> Void in
                                print (" cleverbot => ", answer)

                                expect(answer).toNot(beNil())
                                expect(answer!.characters.count).to(beGreaterThan(1))
                                expect(answer!.characters.count).to(beLessThan(100))
                                cleverBot.ask("What is my name?", completion: { (answer:String?) -> Void in
                                    print (" cleverbot => ", answer)

                                    expect(answer).toNot(beNil())
                                    expect(answer!.characters.count).to(beGreaterThan(1))
                                    expect(answer!.characters.count).to(beLessThan(100))
                                    done()
                                })

                            })

                        })
                    });
                }
            }
            it ("should do conversation when 2 bots are connected") {
                waitUntil(timeout: 30) { done in
                    
                    let cleverBot1 = DRCleverBot();
                    let cleverBot2 = DRCleverBot();
                    cleverBot1.startSession({ () -> () in
                        cleverBot2.startSession({ () -> () in
                            print (" cleverbot2 => ", "Hi!")

                            cleverBot1.ask("Hi!", completion: { (answer:String?) -> Void in
                                print (" cleverbot1 => ", answer)

                                expect(answer).toNot(beNil())
                                expect(answer!.characters.count).to(beGreaterThan(1))
                                expect(answer!.characters.count).to(beLessThan(100))
                                cleverBot2.ask(answer!, completion: { (answer:String?) -> Void in
                                    print (" cleverbot2 => ", answer)

                                    expect(answer).toNot(beNil())
                                    expect(answer!.characters.count).to(beGreaterThan(1))
                                    expect(answer!.characters.count).to(beLessThan(100))
                                    cleverBot1.ask(answer!, completion: { (answer:String?) -> Void in
                                        print (" cleverbot1 => ", answer)

                                        expect(answer).toNot(beNil())
                                        expect(answer!.characters.count).to(beGreaterThan(1))
                                        expect(answer!.characters.count).to(beLessThan(100))
                                        cleverBot2.ask(answer!, completion: { (answer:String?) -> Void in
                                            print (" cleverbot2 => ", answer)

                                            expect(answer).toNot(beNil())
                                            expect(answer!.characters.count).to(beGreaterThan(1))
                                            expect(answer!.characters.count).to(beLessThan(100))
                                            done()
                                            
                                        })
                                    })
                                    
                                })
                                
                            })
                        })
                    })
                }
            }
            
            it ("should not fail if throttled out from the service") {
                waitUntil(timeout: 280) { done in
                    
                    let cleverBot = DRCleverBot();
                    cleverBot.startSession({ () -> () in
                        let gr = dispatch_group_create()
                        var result = [String]()
                        for i in 1...1000 {
                            dispatch_group_enter(gr)
                            
                            cleverBot.ask("Hello?! \(i)", completion: { (answer:String?) -> Void in
                                print(answer)
                                expect(answer).toNot(beNil())
                                expect(answer!.characters.count).to(beGreaterThan(1))
                                expect(answer!.characters.count).to(beLessThan(100))
                                result.append(answer!)
                                dispatch_group_leave(gr)
                            })
                        }
                        
                        dispatch_group_notify(gr, dispatch_get_main_queue(), { () -> Void in
                            expect(result).to(contain("Cleverbot: reloading session... :("))
                            done()
                        })
                        
                    });
                }
            }
            
            
        }
    }
}
