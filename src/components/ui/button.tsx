import React from 'react';

interface ButtonProps {
  children: React.ReactNode;
  onClick?: () => void;
  type?: 'button' | 'submit' | 'reset';
  variant?: 'primary' | 'secondary';
  className?: string;
}

const Button: React.FC<ButtonProps> = ({
  children,
  onClick,
  type = 'button',
  variant = 'primary',
  className = '',
}) => {
  const baseStyle = 'px-4 py-2 rounded-full font-medium text-sm focus:outline-none transition-colors';
  const variantStyle = variant === 'primary'
    ? 'bg-blue-500 text-white hover:bg-blue-600 active:bg-blue-700'
    : 'bg-gray-200 text-gray-800 hover:bg-gray-300 active:bg-gray-400';

  return (
    <button
      type={type}
      onClick={onClick}
      className={`${baseStyle} ${variantStyle} ${className}`}
    >
      {children}
    </button>
  );
};

export default Button;
