// Types for our application
export interface DailyRecord {
  date: string;
  loginTimeSeconds: number;
  callCount: number;
  deleted?: boolean;
}

// Helper functions for time conversion
export function formatSecondsToTime(seconds: number): string {
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const remainingSeconds = seconds % 60;
  
  return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${remainingSeconds.toString().padStart(2, '0')}`;
}

export function parseTimeToSeconds(timeString: string): number {
  const [hours, minutes, seconds] = timeString.split(':').map(Number);
  return hours * 3600 + minutes * 60 + seconds;
}

// Storage functions
export async function saveRecord(record: DailyRecord): Promise<void> {
  const records = await getRecords();
  
  // Find if record with same date exists
  const index = records.findIndex(r => r.date === record.date);
  
  if (index !== -1) {
    if (record.deleted) {
      // Remove the record
      records.splice(index, 1);
    } else {
      // Update existing record
      records[index] = record;
    }
  } else if (!record.deleted) {
    // Add new record
    records.push(record);
  }
  
  // Sort records by date (newest first)
  records.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
  
  // Save to localStorage
  localStorage.setItem('dishtvRecords', JSON.stringify(records));
}

export async function getRecords(): Promise<DailyRecord[]> {
  const recordsJson = localStorage.getItem('dishtvRecords');
  return recordsJson ? JSON.parse(recordsJson) : [];
}

export async function getRecordsByMonth(year: number, month: number): Promise<DailyRecord[]> {
  const records = await getRecords();
  
  return records.filter(record => {
    const recordDate = new Date(record.date);
    return recordDate.getFullYear() === year && recordDate.getMonth() === month;
  });
}

export async function getRecordByDate(date: string): Promise<DailyRecord | null> {
  const records = await getRecords();
  return records.find(record => record.date === date) || null;
}

export async function getAllMonthsWithData(): Promise<string[]> {
  const records = await getRecords();
  
  // Extract unique year-month combinations
  const months = new Set<string>();
  
  records.forEach(record => {
    const [year, month] = record.date.split('-');
    months.add(`${year}-${month}`);
  });
  
  // Convert to array and sort (newest first)
  return Array.from(months).sort().reverse();
}

export function calculateSalary(records: DailyRecord[]) {
  const totalCalls = records.reduce((total, record) => total + record.callCount, 0);
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
}
