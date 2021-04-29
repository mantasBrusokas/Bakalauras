//
//  MostActiveViewController.swift
//  Bakalauras
//
//  Created by Mantas Brusokas on 2021-04-27.
//
import UIKit
import Charts

class MostActiveViewController: UIViewController {
    
    private var posts = [Post]()
    private var array: [String] =  []
    var barChart = BarChartView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        scrollView.isScrollEnabled = true
        scrollView.isUserInteractionEnabled = true
        return scrollView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        scrollView.frame = view.bounds
        scrollView.isUserInteractionEnabled = true
        view.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        view.addSubview(barChart)
        updatePostArray()
    }
    
    private func updatePostArray() {
        DatabaseManager.shared.getAllPosts(completion: { [weak self] result in
            switch result {
            case .success(let postsFromDatabase):
                print("Atnaujino posts Arrayy")
                guard !postsFromDatabase.isEmpty else {
                    print("Posts is empty")
                    return
                }
                self?.posts = postsFromDatabase
                DispatchQueue.main.async {
                    self?.createChart()
                }
            case .failure(let error):
            print("failed to get posts: \(error)")
            }
        })
    }
    
    private func createChart() {
        print("starting posts chart.....")
        
        let formatter = BarChartFormatter()
            
            let xaxis:XAxis = XAxis()

        if !posts.isEmpty {
            for post in posts {
                array.append(post.authorName)
            }
        }  else {
            print("Missing posts")
        }
        
        let values = array.reduce(into: [:]) { counts, word in counts[word, default: 0] += 1 }
        array = []
        let sortedByValueDictionary = values.sorted { $0.1 > $1.1 }
        print(sortedByValueDictionary)
        var entries = [BarChartDataEntry]()
        var i = 0
        var keysArray: [String] = []
        for (key, value) in sortedByValueDictionary {
            if i < 3 {
                print("\(key) -> \(value)")
                keysArray.append(key)
                entries.append(BarChartDataEntry(x: Double(i), y: Double(value)))
                i = i + 1
                
            }
        }
        formatter.setValues(values: keysArray)
        let set = BarChartDataSet(entries: entries, label: nil)
        print(entries)
        set.drawValuesEnabled = false
        let data = BarChartData(dataSet: set)
        

        xaxis.valueFormatter = formatter
        barChart.isUserInteractionEnabled = false
        barChart.leftAxis.labelFont = UIFont.systemFont(ofSize: 13)
        barChart.leftAxis.granularity = 1
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.valueFormatter = xaxis.valueFormatter
        barChart.xAxis.labelFont = UIFont.systemFont(ofSize: 13)
        barChart.chartDescription?.enabled = false
        barChart.legend.enabled = false
        barChart.rightAxis.enabled = false
        barChart.xAxis.granularityEnabled = true
        barChart.xAxis.granularity = 1.0 //default granularity is 1.0, but it is better to be explicit
        barChart.xAxis.decimals = 0
        barChart.data = data
        view.addSubview(barChart)
    }
    
    @objc(BarChartFormatter)
    public class BarChartFormatter: NSObject, IAxisValueFormatter
    {
        var names = [String]()

        public func stringForValue(_ value: Double, axis: AxisBase?) -> String
        {
            return names[Int(value)]
        }

        public func setValues(values: [String])
        {
            self.names = values
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        barChart.frame = CGRect(x: 10, y: 200, width: view.frame.size.width - 20, height: view.frame.size.width)
    }
}

