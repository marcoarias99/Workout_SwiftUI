import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Play, SkipBack, SkipForward, Plus } from 'lucide-react';
import './App.css';

const BACKEND_URL = process.env.REACT_APP_BACKEND_URL;

function App() {
  const [todayData, setTodayData] = useState(null);
  const [routines, setRoutines] = useState([]);
  const [loading, setLoading] = useState(true);
  const [currentView, setCurrentView] = useState('calendar'); // calendar, timer

  useEffect(() => {
    fetchTodayData();
    fetchRoutines();
  }, []);

  const fetchTodayData = async () => {
    try {
      const response = await axios.get(`${BACKEND_URL}/api/today`);
      setTodayData(response.data);
    } catch (error) {
      console.error('Error fetching today data:', error);
    } finally {
      setLoading(false);
    }
  };

  const fetchRoutines = async () => {
    try {
      const response = await axios.get(`${BACKEND_URL}/api/routines`);
      setRoutines(response.data);
    } catch (error) {
      console.error('Error fetching routines:', error);
    }
  };

  const startWorkout = () => {
    setCurrentView('timer');
  };

  const backToCalendar = () => {
    setCurrentView('calendar');
  };

  if (loading) {
    return (
      <div className="loading-screen">
        <div className="loading-text">Loading...</div>
      </div>
    );
  }

  return (
    <div className="app">
      {currentView === 'calendar' ? (
        <CalendarView
          todayData={todayData}
          routines={routines}
          onStartWorkout={startWorkout}
        />
      ) : (
        <TimerView
          todayData={todayData}
          onBack={backToCalendar}
        />
      )}
    </div>
  );
}

function CalendarView({ todayData, routines, onStartWorkout }) {
  return (
    <div className="calendar-view">
      {/* Header */}
      <div className="header">
        <h1 className="header-title">Calendar</h1>
        
        {/* Today's Workout */}
        <div className="today-workout">
          <div className="day-name">
            {todayData?.day}
          </div>
          {todayData?.has_workout ? (
            <div>
              <div className="routine-name">
                {todayData.routine.name}
              </div>
              <div className="exercise-list">
                {todayData.routine.exercises.map((exercise, index) => (
                  <div key={index} className="exercise-item">{exercise.name}</div>
                ))}
              </div>
            </div>
          ) : (
            <div className="no-workout">
              No workout scheduled
            </div>
          )}
        </div>
      </div>

      {/* Start Button */}
      <div className="start-button-container">
        <button
          onClick={onStartWorkout}
          disabled={!todayData?.has_workout}
          className={`start-button ${todayData?.has_workout ? 'enabled' : 'disabled'}`}
        >
          START
        </button>
      </div>

      {/* Routines Section */}
      <div className="routines-section">
        <div className="routines-header">
          <h2 className="routines-title">Routines</h2>
          <button className="add-routine-btn">
            <Plus size={32} />
          </button>
        </div>
        
        <div className="routine-input-label">
          Enter the new routine
        </div>

        <div className="routines-list">
          {routines.map((routine) => (
            <div key={routine.id} className="routine-item">
              <div className="routine-name">
                {routine.name}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function TimerView({ todayData, onBack }) {
  const [currentExerciseIndex, setCurrentExerciseIndex] = useState(0);
  const [timeLeft, setTimeLeft] = useState(0);
  const [isRunning, setIsRunning] = useState(false);
  const [currentSet, setCurrentSet] = useState(1);

  const currentExercise = todayData?.routine?.exercises[currentExerciseIndex];

  useEffect(() => {
    if (currentExercise) {
      setTimeLeft(currentExercise.duration);
      setCurrentSet(1);
    }
  }, [currentExercise]);

  useEffect(() => {
    let interval = null;
    if (isRunning && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft(timeLeft - 1);
      }, 1000);
    } else if (timeLeft === 0 && isRunning) {
      setIsRunning(false);
      // Auto advance to next set or exercise
      if (currentSet < currentExercise.sets) {
        setCurrentSet(currentSet + 1);
        setTimeLeft(currentExercise.duration);
      }
    }
    return () => clearInterval(interval);
  }, [isRunning, timeLeft, currentSet, currentExercise]);

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  const toggleTimer = () => {
    setIsRunning(!isRunning);
  };

  const previousExercise = () => {
    if (currentExerciseIndex > 0) {
      setCurrentExerciseIndex(currentExerciseIndex - 1);
      setIsRunning(false);
    }
  };

  const nextExercise = () => {
    if (currentExerciseIndex < todayData.routine.exercises.length - 1) {
      setCurrentExerciseIndex(currentExerciseIndex + 1);
      setIsRunning(false);
    }
  };

  if (!currentExercise) {
    return (
      <div className="timer-view">
        <div className="timer-error">No exercises available</div>
      </div>
    );
  }

  return (
    <div className="timer-view">
      <button onClick={onBack} className="back-button">
        ← Back
      </button>

      <div className="timer-content">
        <div className="exercise-info">
          <h1 className="exercise-name">
            {currentExercise.name}
          </h1>
          <div className="set-info">
            Set {currentSet} of {currentExercise.sets}
          </div>
        </div>

        <div className="timer-display">
          <div className="timer-digits">
            0:{formatTime(timeLeft)}
          </div>
          
          <div className="timer-controls">
            <button
              onClick={previousExercise}
              disabled={currentExerciseIndex === 0}
              className={`control-button ${currentExerciseIndex === 0 ? 'disabled' : ''}`}
            >
              <SkipBack size={40} />
            </button>
            
            <button onClick={toggleTimer} className="play-button">
              <Play size={50} />
            </button>
            
            <button
              onClick={nextExercise}
              disabled={currentExerciseIndex === todayData.routine.exercises.length - 1}
              className={`control-button ${currentExerciseIndex === todayData.routine.exercises.length - 1 ? 'disabled' : ''}`}
            >
              <SkipForward size={40} />
            </button>
          </div>
        </div>

        <div className="exercise-progress">
          <div className="progress-text">
            Exercise {currentExerciseIndex + 1} of {todayData.routine.exercises.length}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;