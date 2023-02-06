import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), id: 0, advice: "Loading...")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), id: 0, advice: "Loading...")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        
        getAdvice { (id, advice) in
            let date = Date()
            let entry = SimpleEntry(date: date, id: id, advice: advice)
            let nextUpdate = Calendar.current.date(byAdding: .minute, value: 10, to: date)
            let timeline = Timeline(entries: [entry], policy: .after(nextUpdate!))
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let id: Int
    let advice: String
}

struct AdviceWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(.purple.gradient)
            VStack {
                    Text("Advice number: \(entry.id)")
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                    Text(entry.advice)
                        .foregroundColor(.white)
            }
        }
    }
}

// fetch advice

func getAdvice(completion: @escaping (Int, String)->()) {
    let url = "https://api.adviceslip.com/advice"
    
    let session  = URLSession(configuration: .default)
    
    session.dataTask(with: URL(string: url)!) { (data, _, err) in
        if err != nil {
            print(err!)
            return
        }
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
            let advice = jsonData["slip"] as! [String: Any]
            let id = advice["id"] as! Int
            let adviceText = advice["advice"] as! String
            completion (id, adviceText)
        } catch {
            print (err!)
        }
    }.resume ()
}


struct AdviceWidget: Widget {
    let kind: String = "AdviceWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            AdviceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Advice Widget")
        .description("Displays Advices")
    }
}

struct AdviceWidget_Previews: PreviewProvider {
    static var previews: some View {
        AdviceWidgetEntryView(entry: SimpleEntry(date: Date(), id: 0, advice: "Loading..."))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
