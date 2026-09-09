import '../styles/globals.css';

export const metadata = {
  title: 'Aivo Admin Console | Predictive Wellness',
  description: 'Real-time biological monitoring & Huberman Lab RAG pipeline',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body className="bg-background text-slate-100 min-h-screen">
        {children}
      </body>
    </html>
  );
}
