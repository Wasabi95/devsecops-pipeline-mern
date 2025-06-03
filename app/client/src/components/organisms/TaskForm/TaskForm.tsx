// // src/components/organisms/TaskForm/TaskForm.tsx
import Button from '@components/atoms/Button/Button';
import Input from '@components/atoms/Input/Input';
import Label from '@components/atoms/Label/Label';
import Select from '@components/atoms/Select/Select';
import type { RootState } from '@features/store';
import React, { useEffect, useState } from 'react';
import { useSelector } from 'react-redux';
import { toast } from 'react-toastify';
import 'react-toastify/dist/ReactToastify.css';
import { UserService } from '../../../api/services/userService';

interface Employee {
  _id: string;
  name: string;
}

interface TaskFormProps {
  onCreateTask: (taskData: {
    text: string;
    assignedTo: string;
  }) => Promise<void>;
  loading?: boolean;
}

const TaskForm: React.FC<TaskFormProps> = ({
  onCreateTask,
  loading = false,
}) => {
  const [text, setText] = useState<string>('');
  const [assignedTo, setAssignedTo] = useState<string>('');
  const [employees, setEmployees] = useState<Employee[]>([]);
  const { userInfo } = useSelector((state: RootState) => state.auth);

  useEffect(() => {
    const fetchEmployees = async () => {
      if (!userInfo) return;
      try {
        const employeesData = await UserService.getEmployees();
        setEmployees(employeesData);
      } catch (err) {
        console.error('Error fetching employees:', err);
        toast.error('Failed to fetch employees. Please try again.');
      }
    };
    fetchEmployees();
  }, [userInfo]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!text || !assignedTo) {
      toast.warn('Please fill in all fields');
      return;
    }

    try {
      await onCreateTask({ text, assignedTo });
      setText('');
      setAssignedTo('');
      toast.success('Task created successfully!');
    } catch (err) {
      console.error('Error creating task:', err);
      toast.error('Failed to create task. Please try again.');
    }
  };

  return (
    <form onSubmit={handleSubmit} className="task-form">
      <div className="task-form__group">
        <Label htmlFor="taskText" className="task-form__label" required>
          Task Description
        </Label>
        <Input
          id="taskText"
          type="text"
          placeholder="Enter task description"
          value={text}
          onChange={(e) => setText(e.target.value)}
          className="task-form__input"
          required
        />
      </div>

      <div className="task-form__group">
        <Label htmlFor="assignedTo" className="task-form__label" required>
          Assign To
        </Label>
        <Select
          id="assignedTo"
          value={assignedTo}
          onChange={(e) => setAssignedTo(e.target.value)}
          className="task-form__input"
          required
          ariaLabel="Assign To Dropdown"
          ariaRequired
          disabled={loading}
        >
          <option value="">Select Employee</option>
          {employees.map((emp) => (
            <option key={emp._id} value={emp._id}>
              {emp.name}
            </option>
          ))}
        </Select>
      </div>

      <Button type="submit" disabled={loading}>
        {loading ? 'Creating...' : 'Create Task'}
      </Button>
    </form>
  );
};

export default TaskForm;
