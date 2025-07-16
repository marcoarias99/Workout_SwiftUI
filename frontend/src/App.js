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
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-xl">Loading...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
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
    <div className="max-w-md mx-auto bg-white min-h-screen">
      {/* Header */}
      <div className="p-6">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Calendar</h1>
        
        {/* Today's Workout */}
        <div className="text-center mb-8">
          <div className="text-lg font-medium text-gray-900 mb-2">
            {todayData?.day}
          </div>
          {todayData?.has_workout ? (
            <div>
              <div className="text-gray-600 text-sm mb-4">
                {todayData.routine.name}
              </div>
              <div className="text-left text-sm text-gray-700 space-y-1">
                {todayData.routine.exercises.map((exercise, index) => (
                  <div key={index}>{exercise.name}</div>
                ))}
              </div>
            </div>
          ) : (
            <div className="text-gray-600 text-sm">
              No workout scheduled
            </div>
          )}
        </div>
      </div>

      {/* Start Button */}
      <div className="px-6 mb-8">
        <button
          onClick={onStartWorkout}
          disabled={!todayData?.has_workout}
          className={`w-full py-4 rounded-2xl text-white text-xl font-bold ${
            todayData?.has_workout
              ? 'bg-red-500 hover:bg-red-600'
              : 'bg-gray-300 cursor-not-allowed'
          }`}
        >
          START
        </button>
      </div>

      {/* Routines Section */}
      <div className="px-6">
        <div className="flex items-center justify-between mb-4">
          <h2 className="text-2xl font-bold text-gray-900">Routines</h2>
          <button className="text-green-500">
            <Plus size={32} />
          </button>
        </div>
        
        <div className="text-gray-400 text-sm mb-4">
          Enter the new routine
        </div>

        <div className="space-y-2">
          {routines.map((routine) => (
            <div
              key={routine.id}
              className="p-4 bg-gray-50 rounded-lg border"
            >
              <div className="font-medium text-gray-900">
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
      <div className="min-h-screen bg-gradient-to-b from-orange-400 to-black flex items-center justify-center">
        <div className="text-white text-xl">No exercises available</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-400 to-black flex flex-col items-center justify-center text-white">
      <button
        onClick={onBack}
        className="absolute top-6 left-6 text-white text-lg"
      >
        ← Back
      </button>

      <div className="text-center mb-16">
        <h1 className="text-2xl font-bold mb-4">
          {currentExercise.name}
        </h1>
        <div className="text-sm text-gray-200">
          Set {currentSet} of {currentExercise.sets}
        </div>
      </div>

      <div className="text-center mb-16">
        <div className="text-8xl font-semibold mb-8">
          0:{formatTime(timeLeft)}
        </div>
        
        <div className="flex items-center justify-center space-x-12">
          <button
            onClick={previousExercise}
            disabled={currentExerciseIndex === 0}
            className={`p-4 ${
              currentExerciseIndex === 0 ? 'opacity-50' : 'opacity-100'
            }`}
          >
            <SkipBack size={40} />
          </button>
          
          <button
            onClick={toggleTimer}
            className="p-4"
          >
            <Play size={50} />
          </button>
          
          <button
            onClick={nextExercise}
            disabled={currentExerciseIndex === todayData.routine.exercises.length - 1}
            className={`p-4 ${
              currentExerciseIndex === todayData.routine.exercises.length - 1 ? 'opacity-50' : 'opacity-100'
            }`}
          >
            <SkipForward size={40} />
          </button>
        </div>
      </div>

      <div className="text-center">
        <div className="text-sm text-gray-200">
          Exercise {currentExerciseIndex + 1} of {todayData.routine.exercises.length}
        </div>
      </div>
    </div>
  );
}

export default App;