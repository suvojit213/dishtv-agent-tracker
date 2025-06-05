import { useState, useEffect } from 'react';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css';
import { DailyRecord, getRecordsByMonth, formatSecondsToTime, parseTimeToSeconds, saveRecord, getAllMonthsWithData } from './lib/storage';
import jsPDF from 'jspdf';
import 'jspdf-autotable';
import Chart from 'chart.js/auto';

function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [currentDate, setCurrentDate] = useState(new Date());
  const [records, setRecords] = useState<DailyRecord[]>([]);
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [hours, setHours] = useState('00');
  const [minutes, setMinutes] = useState('00');
  const [seconds, setSeconds] = useState('00');
  const [callCount, setCallCount] = useState('0');
  const [showHoursDropdown, setShowHoursDropdown] = useState(false);
  const [showMinutesDropdown, setShowMinutesDropdown] = useState(false);
  const [showSecondsDropdown, setShowSecondsDropdown] = useState(false);
  const [allMonths, setAllMonths] = useState<string[]>([]);
  const [selectedMonth, setSelectedMonth] = useState('');
  const [selectedMonthRecords, setSelectedMonthRecords] = useState<DailyRecord[]>([]);
  const [editingRecord, setEditingRecord] = useState<DailyRecord | null>(null);
  const [chartInstance, setChartInstance] = useState<Chart | null>(null);

  // Month names in English
  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  // Generate hours options (00-23)
  const hoursOptions = Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0'));
  
  // Generate minutes/seconds options (00-59)
  const minutesSecondsOptions = Array.from({ length: 60 }, (_, i) => i.toString().padStart(2, '0'));

  useEffect(() => {
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    
    const fetchRecords = async () => {
      const monthRecords = await getRecordsByMonth(year, month);
      setRecords(monthRecords);
    };
    
    fetchRecords();
  }, [currentDate]);

  useEffect(() => {
    const fetchAllMonths = async () => {
      const months = await getAllMonthsWithData();
      setAllMonths(months);
      if (months.length > 0) {
        setSelectedMonth(months[0]);
      }
    };
    
    fetchAllMonths();
  }, []);

  useEffect(() => {
    if (selectedMonth) {
      const [year, month] = selectedMonth.split('-').map(Number);
      const fetchSelectedMonthRecords = async () => {
        const monthRecords = await getRecordsByMonth(year, month - 1);
        setSelectedMonthRecords(monthRecords);
      };
      
      fetchSelectedMonthRecords();
    }
  }, [selectedMonth]);

  // Effect for chart rendering
  useEffect(() => {
    if (activeTab === 'dashboard') {
      // Destroy previous chart instance if it exists
      if (chartInstance) {
        chartInstance.destroy();
      }
      
      const chartData = prepareChartData();
      if (chartData.labels.length > 0) {
        renderChart(chartData);
      }
    }
    
    // Cleanup function to destroy chart when component unmounts
    return () => {
      if (chartInstance) {
        chartInstance.destroy();
      }
    };
  }, [records, activeTab]);

  const prepareChartData = () => {
    // Sort records by date
    const sortedRecords = [...records].sort((a, b) => 
      new Date(a.date).getTime() - new Date(b.date).getTime()
    );
    
    // Extract dates, login hours, and call counts
    const labels = sortedRecords.map(record => {
      const date = new Date(record.date);
      return date.getDate().toString();
    });
    
    const loginHoursData = sortedRecords.map(record => 
      Math.round(record.loginTimeSeconds / 3600 * 100) / 100
    );
    
    const callCountData = sortedRecords.map(record => record.callCount);
    
    return {
      labels,
      loginHoursData,
      callCountData
    };
  };

  const renderChart = (chartData: { labels: string[], loginHoursData: number[], callCountData: number[] }) => {
    const ctx = document.getElementById('performanceChart') as HTMLCanvasElement;
    if (!ctx) return;
    
    const newChartInstance = new Chart(ctx, {
      type: 'bar',
      data: {
        labels: chartData.labels,
        datasets: [
          {
            label: 'Login Hours',
            data: chartData.loginHoursData,
            backgroundColor: '#2196F3',
            borderColor: '#1976D2',
            borderWidth: 1,
            borderRadius: 5,
            yAxisID: 'y'
          },
          {
            label: 'Call Count',
            data: chartData.callCountData,
            type: 'line',
            borderColor: '#FFC107',
            backgroundColor: 'rgba(255, 193, 7, 0.2)',
            borderWidth: 2,
            pointBackgroundColor: '#FFC107',
            pointBorderColor: '#FFC107',
            pointRadius: 4,
            tension: 0.3,
            yAxisID: 'y1'
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            mode: 'index',
            intersect: false,
            backgroundColor: 'rgba(33, 33, 33, 0.9)',
            titleColor: '#FFFFFF',
            bodyColor: '#FFFFFF',
            borderColor: 'rgba(255, 255, 255, 0.2)',
            borderWidth: 1,
            padding: 10,
            cornerRadius: 8,
            titleFont: {
              size: 14,
              weight: 'bold'
            },
            bodyFont: {
              size: 12
            },
            callbacks: {
              title: function(tooltipItems) {
                const index = tooltipItems[0].dataIndex;
                return `Day ${chartData.labels[index]}`;
              }
            }
          }
        },
        scales: {
          x: {
            title: {
              display: true,
              text: 'Day of Month',
              color: '#AAAAAA',
              font: {
                size: 12
              }
            },
            grid: {
              display: false
            },
            ticks: {
              color: '#AAAAAA'
            }
          },
          y: {
            type: 'linear',
            display: true,
            position: 'left',
            title: {
              display: true,
              text: 'Login Hours',
              color: '#2196F3',
              font: {
                size: 12
              }
            },
            grid: {
              color: 'rgba(255, 255, 255, 0.05)'
            },
            ticks: {
              color: '#AAAAAA'
            },
            min: 0
          },
          y1: {
            type: 'linear',
            display: true,
            position: 'right',
            title: {
              display: true,
              text: 'Call Count',
              color: '#FFC107',
              font: {
                size: 12
              }
            },
            grid: {
              display: false
            },
            ticks: {
              color: '#AAAAAA'
            },
            min: 0
          }
        }
      }
    });
    
    setChartInstance(newChartInstance);
  };

  const handlePrevMonth = () => {
    const newDate = new Date(currentDate);
    newDate.setMonth(newDate.getMonth() - 1);
    setCurrentDate(newDate);
  };

  const handleNextMonth = () => {
    const newDate = new Date(currentDate);
    newDate.setMonth(newDate.getMonth() + 1);
    setCurrentDate(newDate);
  };

  const handleSaveEntry = async () => {
    const timeInSeconds = parseTimeToSeconds(`${hours}:${minutes}:${seconds}`);
    const calls = parseInt(callCount) || 0;
    
    const record: DailyRecord = {
      date: selectedDate.toISOString().split('T')[0],
      loginTimeSeconds: timeInSeconds,
      callCount: calls
    };
    
    if (editingRecord) {
      // If editing, keep the original date
      record.date = editingRecord.date;
    }
    
    await saveRecord(record);
    
    // Reset form
    setHours('00');
    setMinutes('00');
    setSeconds('00');
    setCallCount('0');
    setEditingRecord(null);
    
    // Refresh records
    const year = currentDate.getFullYear();
    const month = currentDate.getMonth();
    const monthRecords = await getRecordsByMonth(year, month);
    setRecords(monthRecords);
    
    // If we're in the all reports view, refresh that data too
    if (selectedMonth) {
      const [selectedYear, selectedMonthNum] = selectedMonth.split('-').map(Number);
      const selectedMonthRecords = await getRecordsByMonth(selectedYear, selectedMonthNum - 1);
      setSelectedMonthRecords(selectedMonthRecords);
    }
    
    // Go back to dashboard
    setActiveTab('dashboard');
  };

  const handleClearEntry = () => {
    setHours('00');
    setMinutes('00');
    setSeconds('00');
    setCallCount('0');
    setEditingRecord(null);
  };

  const handleEditRecord = (record: DailyRecord) => {
    setEditingRecord(record);
    
    // Parse the login time
    const timeString = formatSecondsToTime(record.loginTimeSeconds);
    const [h, m, s] = timeString.split(':');
    
    setHours(h);
    setMinutes(m);
    setSeconds(s);
    setCallCount(record.callCount.toString());
    
    // Set the date
    const [year, month, day] = record.date.split('-').map(Number);
    setSelectedDate(new Date(year, month - 1, day));
    
    setActiveTab('addEntry');
  };

  const handleDeleteRecord = async (record: DailyRecord) => {
    // Filter out the record to delete
    const updatedRecords = records.filter(r => r.date !== record.date);
    setRecords(updatedRecords);
    
    // Update local storage
    await saveRecord({ ...record, deleted: true });
    
    // If we're in the all reports view, refresh that data too
    if (selectedMonth) {
      const [selectedYear, selectedMonthNum] = selectedMonth.split('-').map(Number);
      const selectedMonthRecords = await getRecordsByMonth(selectedYear, selectedMonthNum - 1);
      setSelectedMonthRecords(selectedMonthRecords);
    }
  };

  const calculateTotalLoginHours = (records: DailyRecord[]) => {
    const totalSeconds = records.reduce((total, record) => total + record.loginTimeSeconds, 0);
    return formatSecondsToTime(totalSeconds);
  };

  const calculateTotalCalls = (records: DailyRecord[]) => {
    return records.reduce((total, record) => total + record.callCount, 0);
  };

  const calculateAverageLoginHours = (records: DailyRecord[]) => {
    if (records.length === 0) return '00:00:00';
    const totalSeconds = records.reduce((total, record) => total + record.loginTimeSeconds, 0);
    const averageSeconds = Math.floor(totalSeconds / records.length);
    return formatSecondsToTime(averageSeconds);
  };

  const calculateAverageCalls = (records: DailyRecord[]) => {
    if (records.length === 0) return 0;
    const totalCalls = records.reduce((total, record) => total + record.callCount, 0);
    return (totalCalls / records.length).toFixed(1);
  };

  const calculateSalary = (records: DailyRecord[]) => {
    const totalCalls = calculateTotalCalls(records);
    const totalLoginSeconds = records.reduce((total, record) => total + record.loginTimeSeconds, 0);
    const totalLoginHours = totalLoginSeconds / 3600;
    
    const baseSalary = totalCalls * 4.3; // ₹4.30 per call
    
    // Bonus of ₹2000 if 750+ calls and 100+ hours
    const bonus = (totalCalls >= 750 && totalLoginHours >= 100) ? 2000 : 0;
    
    return {
      baseSalary,
      bonus,
      totalSalary: baseSalary + bonus
    };
  };

  const generatePDF = () => {
    if (!selectedMonth) return;
    
    const [year, month] = selectedMonth.split('-').map(Number);
    const monthName = monthNames[month - 1];
    
    const doc = new jsPDF();
    
    // Title
    doc.setFontSize(20);
    doc.text(`DishTV Agent Performance Report`, 105, 20, { align: 'center' });
    
    doc.setFontSize(16);
    doc.text(`${monthName} ${year}`, 105, 30, { align: 'center' });
    
    // Summary section
    doc.setFontSize(14);
    doc.text('Performance Summary', 14, 45);
    
    const totalLoginHours = calculateTotalLoginHours(selectedMonthRecords);
    const totalCalls = calculateTotalCalls(selectedMonthRecords);
    const averageLoginHours = calculateAverageLoginHours(selectedMonthRecords);
    const averageCalls = calculateAverageCalls(selectedMonthRecords);
    
    doc.setFontSize(12);
    doc.text(`Total Login Hours: ${totalLoginHours}`, 14, 55);
    doc.text(`Total Calls: ${totalCalls}`, 14, 65);
    doc.text(`Average Login Hours/Day: ${averageLoginHours}`, 14, 75);
    doc.text(`Average Calls/Day: ${averageCalls}`, 14, 85);
    
    // Salary section
    const salary = calculateSalary(selectedMonthRecords);
    
    doc.setFontSize(14);
    doc.text('Salary Calculation', 14, 105);
    
    doc.setFontSize(12);
    doc.text(`Base Salary (₹4.30/call): ₹${salary.baseSalary.toFixed(2)}`, 14, 115);
    doc.text(`Bonus (750+ calls & 100+ hours): ₹${salary.bonus.toFixed(2)}`, 14, 125);
    doc.text(`Total Estimated Salary: ₹${salary.totalSalary.toFixed(2)}`, 14, 135);
    
    // Daily entries table
    doc.setFontSize(14);
    doc.text('Daily Entries', 14, 155);
    
    const tableData = selectedMonthRecords.map(record => {
      const dateParts = record.date.split('-');
      const formattedDate = `${dateParts[2]}/${dateParts[1]}/${dateParts[0]}`;
      return [
        formattedDate,
        formatSecondsToTime(record.loginTimeSeconds),
        record.callCount.toString()
      ];
    });
    
    doc.autoTable({
      startY: 160,
      head: [['Date', 'Login Hours', 'Call Count']],
      body: tableData,
    });
    
    // Footer
    const pageCount = doc.internal.pages.length - 1;
    doc.setFontSize(10);
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      doc.text(`Generated on ${new Date().toLocaleDateString()} | Page ${i} of ${pageCount}`, 105, doc.internal.pageSize.height - 10, { align: 'center' });
    }
    
    // Save the PDF
    doc.save(`DishTV_Report_${monthName}_${year}.pdf`);
  };

  const renderDashboard = () => {
    const totalLoginHours = calculateTotalLoginHours(records);
    const totalCalls = calculateTotalCalls(records);
    const salary = calculateSalary(records);
    
    return (
      <div>
        <div className="month-nav">
          <button className="month-nav-button" onClick={handlePrevMonth}>&lt;</button>
          <h2>{monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}</h2>
          <button className="month-nav-button" onClick={handleNextMonth}>&gt;</button>
        </div>
        
        <div className="card stat-card">
          <div className="icon-circle">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <circle cx="12" cy="12" r="10"></circle>
              <polyline points="12 6 12 12 16 14"></polyline>
            </svg>
          </div>
          <div className="stat-label">Total Login Hours</div>
          <div className="stat-value">{totalLoginHours}</div>
        </div>
        
        <div className="card stat-card">
          <div className="icon-circle">
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"></path>
            </svg>
          </div>
          <div className="stat-label">Total Calls</div>
          <div className="stat-value">{totalCalls}</div>
        </div>
        
        <div className="card chart-card">
          <div className="chart-legend">
            <div className="legend-item">
              <div className="legend-color bar"></div>
              <span>Login Hours</span>
            </div>
            <div className="legend-item">
              <div className="legend-color line"></div>
              <span>Call Count</span>
            </div>
          </div>
          <div className="chart-container">
            <canvas id="performanceChart" height="200"></canvas>
          </div>
        </div>
        
        <div className="card">
          <h3 className="section-title">Estimated Salary</h3>
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
        
        <div className="dashboard-actions">
          <button 
            className="dashboard-action-button monthly-performance"
            onClick={() => setActiveTab('monthlyReport')}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
              <line x1="16" y1="2" x2="16" y2="6"></line>
              <line x1="8" y1="2" x2="8" y2="6"></line>
              <line x1="3" y1="10" x2="21" y2="10"></line>
            </svg>
            Monthly Performance
          </button>
          
          <button 
            className="dashboard-action-button all-entries"
            onClick={() => setActiveTab('allReports')}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <line x1="8" y1="6" x2="21" y2="6"></line>
              <line x1="8" y1="12" x2="21" y2="12"></line>
              <line x1="8" y1="18" x2="21" y2="18"></line>
              <line x1="3" y1="6" x2="3.01" y2="6"></line>
              <line x1="3" y1="12" x2="3.01" y2="12"></line>
              <line x1="3" y1="18" x2="3.01" y2="18"></line>
            </svg>
            All Entries
          </button>
        </div>
        
        {records.length > 0 ? (
          <div className="card">
            <h3 className="section-title">Recent Entries</h3>
            {records.slice(0, 5).map((record, index) => (
              <div className="entry-item" key={index}>
                <div>
                  <div>{new Date(record.date).toLocaleDateString('en-US', { weekday: 'short', day: 'numeric', month: 'short' })}</div>
                  <div style={{ display: 'flex', gap: '1rem', marginTop: '0.25rem' }}>
                    <span style={{ color: '#2196F3' }}>{formatSecondsToTime(record.loginTimeSeconds)}</span>
                    <span style={{ color: '#FFC107' }}>{record.callCount} calls</span>
                  </div>
                </div>
                <div className="entry-actions">
                  <button className="edit-button" onClick={() => handleEditRecord(record)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                      <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                    </svg>
                  </button>
                  <button className="delete-button" onClick={() => handleDeleteRecord(record)}>
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                      <polyline points="3 6 5 6 21 6"></polyline>
                      <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      <line x1="10" y1="11" x2="10" y2="17"></line>
                      <line x1="14" y1="11" x2="14" y2="17"></line>
                    </svg>
                  </button>
                </div>
              </div>
            ))}
            {records.length > 5 && (
              <button className="view-all-button" onClick={() => setActiveTab('monthlyReport')}>
                View Monthly Report
              </button>
            )}
          </div>
        ) : (
          <div className="card">
            <p>No entries for this month</p>
          </div>
        )}
      </div>
    );
  };

  const renderAddEntry = () => {
    return (
      <div>
        <button className="back-button" onClick={() => setActiveTab('dashboard')}>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
          </svg>
          Add New Entry
        </button>
        
        <div className="form-group">
          <label className="form-label">Date</label>
          <DatePicker 
            selected={selectedDate}
            onChange={(date: Date | null) => date && setSelectedDate(date)}
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
          <button className="clear-button" onClick={handleClearEntry}>Clear</button>
          <button className="save-button" onClick={handleSaveEntry}>Save Entry</button>
        </div>
      </div>
    );
  };

  const renderMonthlyReport = () => {
    const totalLoginHours = calculateTotalLoginHours(records);
    const totalCalls = calculateTotalCalls(records);
    const averageLoginHours = calculateAverageLoginHours(records);
    const averageCalls = calculateAverageCalls(records);
    const salary = calculateSalary(records);
    
    return (
      <div>
        <button className="back-button" onClick={() => setActiveTab('dashboard')}>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
          </svg>
          Monthly Report
        </button>
        
        <div className="month-nav">
          <button className="month-nav-button" onClick={handlePrevMonth}>&lt;</button>
          <h2>{monthNames[currentDate.getMonth()]} {currentDate.getFullYear()}</h2>
          <button className="month-nav-button" onClick={handleNextMonth}>&gt;</button>
        </div>
        
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
                      <button className="edit-button" onClick={() => handleEditRecord(record)}>
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                          <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                          <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                        </svg>
                      </button>
                      <button className="delete-button" onClick={() => handleDeleteRecord(record)}>
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
        </div>
      </div>
    );
  };

  const renderAllReports = () => {
    return (
      <div>
        <button className="back-button" onClick={() => setActiveTab('dashboard')}>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="19" y1="12" x2="5" y2="12"></line>
            <polyline points="12 19 5 12 12 5"></polyline>
          </svg>
          All Reports
        </button>
        
        <div className="report-filters">
          <select 
            className="report-filter-select"
            value={selectedMonth}
            onChange={(e) => setSelectedMonth(e.target.value)}
          >
            {allMonths.map((month) => {
              const [year, monthNum] = month.split('-');
              const monthName = monthNames[parseInt(monthNum) - 1];
              return (
                <option key={month} value={month}>
                  {monthName} {year}
                </option>
              );
            })}
          </select>
          
          <button 
            className="download-button"
            onClick={generatePDF}
            disabled={!selectedMonth || selectedMonthRecords.length === 0}
          >
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
              <polyline points="7 10 12 15 17 10"></polyline>
              <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            Download PDF
          </button>
        </div>
        
        {selectedMonth && selectedMonthRecords.length > 0 ? (
          <>
            <div className="card">
              <div className="report-header">
                <h3 className="report-title">Monthly Summary</h3>
                <div className="report-date">
                  {(() => {
                    const [year, monthNum] = selectedMonth.split('-');
                    const monthName = monthNames[parseInt(monthNum) - 1];
                    return `${monthName} ${year}`;
                  })()}
                </div>
              </div>
              
              <div className="report-summary">
                <div className="report-stat">
                  <div className="report-stat-label">Total Login Hours</div>
                  <div className="report-stat-value">{calculateTotalLoginHours(selectedMonthRecords)}</div>
                </div>
                <div className="report-stat">
                  <div className="report-stat-label">Total Calls</div>
                  <div className="report-stat-value">{calculateTotalCalls(selectedMonthRecords)}</div>
                </div>
                <div className="report-stat">
                  <div className="report-stat-label">Average Hours/Day</div>
                  <div className="report-stat-value">{calculateAverageLoginHours(selectedMonthRecords)}</div>
                </div>
                <div className="report-stat">
                  <div className="report-stat-label">Average Calls/Day</div>
                  <div className="report-stat-value">{calculateAverageCalls(selectedMonthRecords)}</div>
                </div>
              </div>
              
              <div className="salary-section">
                <h4 className="salary-title">Salary Calculation</h4>
                <div className="salary-row">
                  <span>Base Salary (₹4.30/call)</span>
                  <span>₹{calculateSalary(selectedMonthRecords).baseSalary.toFixed(0)}</span>
                </div>
                <div className="salary-row">
                  <span>Bonus (750+ calls & 100+ hours)</span>
                  <span>₹{calculateSalary(selectedMonthRecords).bonus.toFixed(0)}</span>
                </div>
                <div className="salary-row salary-total">
                  <span>Total Estimated Salary</span>
                  <span>₹{calculateSalary(selectedMonthRecords).totalSalary.toFixed(0)}</span>
                </div>
              </div>
            </div>
            
            <div className="card">
              <h3 className="section-title">Daily Entries</h3>
              <table className="data-table">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Login Hours</th>
                    <th>Call Count</th>
                  </tr>
                </thead>
                <tbody>
                  {selectedMonthRecords.map((record, index) => (
                    <tr key={index}>
                      <td>{new Date(record.date).toLocaleDateString('en-US', { weekday: 'short', day: 'numeric', month: 'short' })}</td>
                      <td>{formatSecondsToTime(record.loginTimeSeconds)}</td>
                      <td>{record.callCount}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        ) : (
          <div className="card">
            <p>No data available for the selected month</p>
          </div>
        )}
      </div>
    );
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return renderDashboard();
      case 'addEntry':
        return renderAddEntry();
      case 'monthlyReport':
        return renderMonthlyReport();
      case 'allReports':
        return renderAllReports();
      default:
        return renderDashboard();
    }
  };

  return (
    <div className="app">
      <div className="app-header">
        <div className="header-content">
          <h1>Suvojeet Tracker</h1>
          <p>DishTV Performance Tracker</p>
        </div>
        <div className="made-with">Made with ❤️ by Suvojeet</div>
      </div>
      
      <div className="app-content">
        {renderContent()}
      </div>
      
      <button 
        className="fab"
        onClick={() => setActiveTab('addEntry')}
      >
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <line x1="12" y1="5" x2="12" y2="19"></line>
          <line x1="5" y1="12" x2="19" y2="12"></line>
        </svg>
      </button>
      
      <div className="bottom-nav">
        <button 
          className={`bottom-nav-item ${activeTab === 'dashboard' ? 'active' : ''}`}
          onClick={() => setActiveTab('dashboard')}
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
            <polyline points="9 22 9 12 15 12 15 22"></polyline>
          </svg>
          Dashboard
        </button>
        <button 
          className={`bottom-nav-item ${activeTab === 'addEntry' ? 'active' : ''}`}
          onClick={() => setActiveTab('addEntry')}
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="12" cy="12" r="10"></circle>
            <line x1="12" y1="8" x2="12" y2="16"></line>
            <line x1="8" y1="12" x2="16" y2="12"></line>
          </svg>
          Add Entry
        </button>
        <button 
          className={`bottom-nav-item ${activeTab === 'allReports' ? 'active' : ''}`}
          onClick={() => setActiveTab('allReports')}
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <line x1="8" y1="6" x2="21" y2="6"></line>
            <line x1="8" y1="12" x2="21" y2="12"></line>
            <line x1="8" y1="18" x2="21" y2="18"></line>
            <line x1="3" y1="6" x2="3.01" y2="6"></line>
            <line x1="3" y1="12" x2="3.01" y2="12"></line>
            <line x1="3" y1="18" x2="3.01" y2="18"></line>
          </svg>
          All Entries
        </button>
      </div>
    </div>
  );
}

export default App;
