// Simpliest Weather Parameters Prometheus exporter
// As weather source used weatherapi.com service
package main

import (
    "os"
    "fmt"
    "log"
    "time"
    "io/ioutil"
    "errors"
    "net/http"
    "encoding/json"
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promauto"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

const (
    PORT                    = 8612
    API_URL                 = "https://api.weatherapi.com/v1/current.json?key=%s&q=%s"
    WEATHER_UPDATE_INTERVAL = 10 * time.Minute
)

type WeatherReportParameters struct {
    TempC float64 `json:"temp_c"`
}

type WeatherReport struct {
    Current WeatherReportParameters `json:"current"`
}

func getCurrentWeather(api_key, city string) (*WeatherReport, error) {
    res, err := http.Get(fmt.Sprintf(API_URL, api_key, city))
    if err != nil {
        return nil, err
    }
    if res.StatusCode != 200 {
        return nil, errors.New(fmt.Sprintf("API Error: %s", res.Status))
    }
    defer res.Body.Close()

    json_body, err := ioutil.ReadAll(res.Body)
    if err != nil {
        return nil, err
    }

    var weather_report WeatherReport
    if err := json.Unmarshal(json_body, &weather_report); err != nil {
        return nil, err
    }
    return &weather_report, nil
}

func updateTemperatureMetric(api_key, city string) {
    metricTempC := promauto.NewGauge(prometheus.GaugeOpts{
            Name       : "weather_temp_c",
            Help       : "Temperature in the City",
            ConstLabels: map[string]string{"city": city,},
    })

    go func() {
        for {
            weather_report, err := getCurrentWeather(api_key, city)
            if err != nil {
                log.Fatal(err)
            } else {
                metricTempC.Set(weather_report.Current.TempC)
            }
            time.Sleep(WEATHER_UPDATE_INTERVAL)
        }
    }()

    log.Printf("Temperature collector started for city: %s\n", city)
}

func main() {
    api_key := os.Getenv("WE_APIKEY")
    city    := os.Getenv("WE_CITY")

    if api_key == "" || city == "" {
        log.Fatal("Required parameter not found\n")
        os.Exit(255)
    }

    updateTemperatureMetric(api_key, city)

    http.Handle("/metrics", promhttp.Handler())
    log.Printf("Starting exporter on port %d\n", PORT)
    if err := http.ListenAndServe(fmt.Sprintf(":%d", PORT), nil); err != nil {
        log.Fatal(err)
    }
    log.Println("Exporter stopped")
}
