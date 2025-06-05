import React, { useState, useEffect } from 'react';
import { DailyRecord, getRecordsByMonth, formatSecondsToTime, calculateSalary } from '../lib/storage';


interface MonthlyDashboardProps {
  year: number;
  month: number;
  onEditRecord: (record: DailyRecord) => void;
  onDeleteRecord: (record: DailyRecord) => void;
}

const MonthlyDashboard: React.FC<MonthlyDashboardProps> = ({ year, month, onEditRecord, onDeleteRecord }) => {
  const [records, setRecords] = useState<DailyRecord[]>([]);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    const fetchRecords = async () => {
      setLoading(true);
      const monthRecords = await getRecordsByMonth(year, month);
      setRecords(monthRecords);
      setLoading(false);
    };
    
    fetchRecords();
  }, [year, month]);
  
  if (loading) {
    return <div>Loading...</div>;
  }
  
  // Calculate statistics
  const totalLoginHours = formatSecondsToTime(
    records.reduce((sum, record) => sum + record.loginTimeSeconds, 0)
  );
  
  const totalCalls = records.reduce((sum, record) => sum + record.callCount, 0);
  
  const averageLoginSeconds = records.length > 0 
    ? records.reduce((sum, record) => sum + record.loginTimeSeconds, 0) / records.length 
    : 0;
  
  const averageLoginHours = formatSecondsToTime(Math.floor(averageLoginSeconds));
  
  const averageCalls = records.length > 0 
    ? (records.reduce((sum, record) => sum + record.callCount, 0) / records.length).toFixed(1) 
    : '0.0';
  
  const salary = calculateSalary(records);
  
  return (
    <div>
      <div className="card">
        <div className="report-summary">
          <div className="report-stat">
            <div className="report-stat-label">Total Login Hours:</div>
            <div className="report-stat-value">{totalLoginHours}</div>
          </div>
          <div className="report-stat">
            <div className="report-stat-label">Total Calls:</div>
            <div className="report-stat-value">{totalCalls}</div>
          </div>
          <div className="report-stat">
            <div className="report-stat-label">Average Login Hours/Day:</div>
            <div className="report-stat-value">{averageLoginHours}</div>
          </div>
          <div className="report-stat">
            <div className="report-stat-label">Average Calls/Day:</div>
            <div className="report-stat-value">{averageCalls}</div>
          </div>
        </div>
      </div>
      
      <div className="card">
        <h3 className="section-title">Salary Calculation</h3>
        <div className="salary-section">
          <div className="salary-row">
            <span>Base Salary (₹4.30/call)</span>
            <span>₹{salary.baseSalary.toFixed(0)}</span>
          </div>
          <div className="salary-row">
            <span>Bonus (750+ calls & 100+ hours)</span>
            <span>₹{salary.bonus.toFixed(0)}</span>
          </div>
          <div className="salary-row salary-total">
            <span>Total Estimated Salary</span>
            <span>₹{salary.totalSalary.toFixed(0)}</span>
          </div>
        </div>
      </div>
      
      <div className="card">
        <h3 className="section-title">Daily Entries</h3>
        {records.length > 0 ? (
          <table className="data-table">
            <thead>
              <tr>
                <th>Date</th>
                <th>Login Hours</th>
                <th>Call Count</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {records.map((record, index) => (
                <tr key={index}>
                  <td>{new Date(record.date).toLocaleDateString('en-US', { weekday: 'short', day: 'numeric', month: 'short' })}</td>
                  <td>{formatSecondsToTime(record.loginTimeSeconds)}</td>
                  <td>{record.callCount}</td>
                  <td>
                    <div className="entry-actions">
                      <button className="edit-button" onClick={() => onEditRecord(record)}>
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                      </button>
                      <button className="delete-button" onClick={() => onDeleteRecord(record)}>
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <polyline points="3 6 5 6 21 6"></polyline>
                          <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                          <line x1="10" y1="11" x2="10" y2="17"></line>
                          <line x1="14" y1="11" x2="14" y2="17"></line>
                        </svg>
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        ) : (
          <p>No entries for this month</p>
        )}
      </div>
    </div>
  );
};

export default MonthlyDashboard;
