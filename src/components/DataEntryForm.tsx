import React, { useState, useEffect } from 'react';
import { DailyRecord, formatSecondsToTime, parseTimeToSeconds, saveRecord, getRecordByDate } from '../lib/storage';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';

interface DataEntryFormProps {
  onSave: () => void;
  editDate?: string;
}

const DataEntryForm: React.FC<DataEntryFormProps> = ({ onSave, editDate }) => {
  const [date, setDate] = useState(new Date());
  const [hours, setHours] = useState('00');
  const [minutes, setMinutes] = useState('00');
  const [seconds, setSeconds] = useState('00');
  const [callCount, setCallCount] = useState('0');
  const [showHoursDropdown, setShowHoursDropdown] = useState(false);
  const [showMinutesDropdown, setShowMinutesDropdown] = useState(false);
  const [showSecondsDropdown, setShowSecondsDropdown] = useState(false);

  useEffect(() => {
    const loadExistingRecord = async () => {
      if (editDate) {
        const existingRecord = await getRecordByDate(editDate);
        if (existingRecord) {
          const [year, month, day] = existingRecord.date.split('-').map(Number);
          setDate(new Date(year, month - 1, day));
          
          // Parse the login time
          const timeString = formatSecondsToTime(existingRecord.loginTimeSeconds);
          const [h, m, s] = timeString.split(':');
          
          setHours(h);
          setMinutes(m);
          setSeconds(s);
          setCallCount(existingRecord.callCount.toString());
        }
      }
    };
    
    loadExistingRecord();
  }, [editDate]);

  const handleSave = async () => {
    const formattedDate = date.toISOString().split('T')[0];
    const loginTimeSeconds = parseTimeToSeconds(`${hours}:${minutes}:${seconds}`);
    const calls = parseInt(callCount) || 0;
    
    const record: DailyRecord = {
      date: formattedDate,
      loginTimeSeconds,
      callCount: calls
    };
    
    await saveRecord(record);
    
    // Reset form
    if (!editDate) {
      setHours('00');
      setMinutes('00');
      setSeconds('00');
      setCallCount('0');
    }
    
    onSave();
  };

  const handleClear = () => {
    setHours('00');
    setMinutes('00');
    setSeconds('00');
    setCallCount('0');
  };

  // Generate hours options (00-23)
  const hoursOptions = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'));
  
  // Generate minutes/seconds options (00-59)
  const minutesSecondsOptions = Array.from({ length: 60 }, (_, i) => i.toString().padStart(2, '0'));

  return (
    <div>
      <button className="back-button" onClick={onSave}>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <line x1="19" y1="12" x2="5" y2="12"></line>
          <polyline points="12 19 5 12 12 5"></polyline>
        </svg>
        Add New Entry
      </button>
      
      <div className="form-group">
        <label className="form-label">Date</label>
        <DatePicker 
          selected={date}
          onChange={(newDate: Date | null) => newDate && setDate(newDate)}
          dateFormat="yyyy-MM-dd"
          className="date-picker-input"
          wrapperClassName="date-picker-wrapper"
        />
      </div>
      
      <div className="form-group">
        <label className="form-label">Login Hours</label>
        <div className="time-inputs">
          <div className="time-select-container">
            <div 
              className="time-select"
              onClick={() => {
                setShowHoursDropdown(!showHoursDropdown);
                setShowMinutesDropdown(false);
                setShowSecondsDropdown(false);
              }}
            >
              {hours}
            </div>
            {showHoursDropdown && (
              <div className="time-dropdown">
                {hoursOptions.map((hour) => (
                  <div 
                    key={hour} 
                    className={`time-option ${hour === hours ? 'selected' : ''}`}
                    onClick={() => {
                      setHours(hour);
                      setShowHoursDropdown(false);
                    }}
                  >
                    {hour}
                  </div>
                ))}
              </div>
            )}
          </div>
          <div className="time-separator">:</div>
          <div className="time-select-container">
            <div 
              className="time-select"
              onClick={() => {
                setShowMinutesDropdown(!showMinutesDropdown);
                setShowHoursDropdown(false);
                setShowSecondsDropdown(false);
              }}
            >
              {minutes}
            </div>
            {showMinutesDropdown && (
              <div className="time-dropdown">
                {minutesSecondsOptions.map((minute) => (
                  <div 
                    key={minute} 
                    className={`time-option ${minute === minutes ? 'selected' : ''}`}
                    onClick={() => {
                      setMinutes(minute);
                      setShowMinutesDropdown(false);
                    }}
                  >
                    {minute}
                  </div>
                ))}
              </div>
            )}
          </div>
          <div className="time-separator">:</div>
          <div className="time-select-container">
            <div 
              className="time-select"
              onClick={() => {
                setShowSecondsDropdown(!showSecondsDropdown);
                setShowHoursDropdown(false);
                setShowMinutesDropdown(false);
              }}
            >
              {seconds}
            </div>
            {showSecondsDropdown && (
              <div className="time-dropdown">
                {minutesSecondsOptions.map((second) => (
                  <div 
                    key={second} 
                    className={`time-option ${second === seconds ? 'selected' : ''}`}
                    onClick={() => {
                      setSeconds(second);
                      setShowSecondsDropdown(false);
                    }}
                  >
                    {second}
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
      
      <div className="form-group">
        <label className="form-label">Call Count</label>
        <input
          type="number"
          className="call-input"
          value={callCount}
          onChange={(e) => setCallCount(e.target.value)}
          placeholder="0"
        />
      </div>
      
      <div className="action-buttons">
        <button className="clear-button" onClick={handleClear}>Clear</button>
        <button className="save-button" onClick={handleSave}>Save Entry</button>
      </div>
    </div>
  );
};

export default DataEntryForm;
