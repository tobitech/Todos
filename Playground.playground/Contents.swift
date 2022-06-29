import Combine
import Dispatch
import Foundation

var cancellables: Set<AnyCancellable> = []

//Just(1)
//  .debounce(for: <#T##SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>, scheduler: <#T##Scheduler#>)

//DispatchQueue.main.schedule {
//  print("DispatchQueue")
//}
//
//DispatchQueue.main.schedule(after: .init(.now() + 1)) {
//  print("DispatchQueue", "delayed")
//}
//
//DispatchQueue.main.schedule(after: .init(.now() + 1), interval: 1) {
//  print("DispatchQueue", "timer")
//}.store(in: &cancellables)
//
//RunLoop.main.schedule {
//  print("RunLoop")
//}
//
//RunLoop.main.schedule(after: .init(Date() + 1)) {
//  print("RunLoop", "delayed")
//}
//
//RunLoop.main.schedule(after: .init(Date() + 1), interval: 1) {
//  print("RunLoop", "timer")
//}.store(in: &cancellables)
//
//OperationQueue.main.schedule {
//  print("OperationQueue")
//}
//
//OperationQueue.main.schedule(after: .init(Date() + 1)) {
//  print("OperationQueue", "delayed")
//}
//
//OperationQueue.main.schedule(after: .init(Date() + 1), interval: 1) {
//  print("OperationQueue", "timer")
//}.store(in: &cancellables)


// this shows that combine operators take a scheduler as argument.
//Just(1)
//  .receive(on: <#T##Scheduler#>)
//  .subscribe(on: <#T##Scheduler#>)
//  .timeout(<#T##interval: SchedulerTimeIntervalConvertible & Comparable & SignedNumeric##SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>, scheduler: <#T##Scheduler#>)
//  .throttle(for: <#T##SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>, scheduler: <#T##Scheduler#>, latest: <#T##Bool#>)
//  .debounce(for: <#T##SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>, scheduler: <#T##Scheduler#>)
//  .delay(for: <#T##SchedulerTimeIntervalConvertible & Comparable & SignedNumeric#>, scheduler: <#T##Scheduler#>)


// this gives us a whole new scheduler, except we control its passage of time.
let scheduler = DispatchQueue.testScheduler

// running this alone won't do anything
// that's because the scheduler won't do anything
// until we tell it to move time forward
scheduler.schedule {
  print("TestScheduler")
}

// this will move time forward to execute any work that is waiting to be done at this moment.
// and with this we will finally get something printed.
scheduler.advance()

// passing `.init(.now() + 1)` refers to the current time
// this isn't correct because it's not what the test scheduler understands to be it's own now
//scheduler.schedule(after: .init(.now() + 1)) {
//  print("TestScheduler", "delayed")
//}

// right way to do it.
scheduler.schedule(after: scheduler.now.advanced(by: 1)) {
  print("TestScheduler", "delayed")
}

// using only advanced wouldn't work because it's not up to the time that that work is waiting to be executed.
// .advance() will only execute work that is waiting to be executed up till that very moment.
// we pass in by: 1 to execute work waiting to be executed up till 1 sec of time.
scheduler.advance(by: 1)

scheduler.schedule(after: scheduler.now, interval: 1) {
  print("TestScheduler", "timer")
}

// there is a unit of work waiting to be done immediately specified by `scheduler.now` above.
scheduler.advance()
scheduler.advance(by: 5) // we will get the timer printed 5 times

// for us to get as many timer, we can pass 1000 totally controllable.
// for the other schedulers: DispatchQueue and co, we will literally have to wait for 1000sec. which isn't controllable.
scheduler.advance(by: 1000) //
