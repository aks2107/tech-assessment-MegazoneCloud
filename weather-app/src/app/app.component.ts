import { Component, OnInit } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { environment } from '../environments/environment';

/*
This is the interface which defines the data to get from weather API.
*/
interface WeatherData {
  // Information about location and the place
  location: {
    name: string; // Name of city
    country: string; // Name of country
  };
  // Information about current temperature in Celsius and Fahrenheit
  // Icon image and icon description based on current temperature
  current: {
    temp_c: number; // Celsius temp
    temp_f: number; // Fahrenheit temp
    condition: {
      text: string; // Icon description
      icon: string; // Icon image
    };
  };
  // Temperature forecast for the future in Celsius and Fahrenheit
  // Icon image and icon description based on future temperature
  forecast: {
    forecastday: Array<{
      date: string; // Date of forecast
      day: {
        avgtemp_c: number; // Average Celsius temp
        avgtemp_f: number; // Average Fahrenheit temp
        condition: {
          text: string; // Icon description
          icon: string; // Icon image
        };
      };
    }>;
  };
}

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './app.component.html',
})

export class AppComponent{ // Make class available to other files
  weatherData: WeatherData | null = null; 
  isCelsius: boolean = true;
  loading: boolean = false; // check for loading data
  error: string = ''; 
  searchQuery: string = ''; // storing input from user

  private apiUrl = environment.weatherApiUrl; // gets API url from environment file
  private apiKey = environment.weatherApiKey; // get API key from environment file

  constructor(private http: HttpClient) {}

  // This method takes a city inputted by the user and gets weather data from API
  loadWeatherByCity(city: string){
    this.loading = true;
    this.error = '';

    this.http.get<WeatherData>( // HTTP get request to get data
      `${this.apiUrl}/forecast.json?key=${this.apiKey}&q=${city}&days=2&aqi=no&alerts=no` // API URL to get data for current day and next day
    ).subscribe({ // Waits for data to be received
      next: (data) => { // If the API call worked then there is weather information
        this.weatherData = data;
        this.loading = false;
      },
      error: (err) => { // If API call failed then we print out error message
        this.error = 'Failed to load weather data. Please try again.';
        this.loading = false;
        console.error(err);
      }
    });
  }

  // This method is used to switch between Celsius and Fahrenheit
  toggleTemperatureUnit(){
    this.isCelsius = !this.isCelsius;
  }

  // This method handles the function of when a user clicks search after typing in a city
  onSearch(){
    if (this.searchQuery.trim()){
      this.loadWeatherByCity(this.searchQuery.trim());
    }
  }
}
