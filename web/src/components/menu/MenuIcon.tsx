import type { CSSProperties } from 'react';

interface MenuIconProps {
  icon: string;
  className?: string;
  style?: CSSProperties;
}

function isImageUrl(icon: string): boolean {
  return icon.startsWith('http://') || icon.startsWith('https://') || icon.startsWith('data:');
}

export function MenuIcon({ icon, className = '', style }: MenuIconProps) {
  if (isImageUrl(icon)) {
    return (
      <img
        src={icon}
        alt=""
        draggable={false}
        className={className}
        style={{ objectFit: 'contain', ...style }}
      />
    );
  }
  return <i className={`fa-solid fa-${icon} ${className}`} style={style} />;
}
