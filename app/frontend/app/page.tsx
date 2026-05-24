"use client";

import { useState } from "react";

export default function Home() {
  const [mensaje, setMensaje] = useState("");
  const [darkMode, setDarkMode] = useState(false);
  const [isRecording, setIsRecording] = useState(false);
  const [chats, setChats] = useState([
    { rol: "bot", contenido: "¿En qué te puedo ayudar hoy?" }
  ]);
  const [historial, setHistorial] = useState<string[]>(["Consulta de Nómina", "Políticas AWS S3"]);

  const enviarMensaje = () => {
    if (!mensaje.trim()) return;
    if (!historial.includes(mensaje.substring(0, 20))) {
      setHistorial([mensaje.substring(0, 25) + "...", ...historial]);
    }
    const nuevos = [...chats, { rol: "user", contenido: mensaje }];
    setChats(nuevos);
    setMensaje("");
    setTimeout(() => {
      setChats([...nuevos, { rol: "bot", contenido: "Respuesta generada mediante RAG (Bedrock + S3)." }]);
    }, 1000);
  };

  return (
    <main className={`${darkMode ? "dark" : ""} flex h-screen bg-white dark:bg-black transition-colors duration-500`}>
      
      {/* 1. BARRA LATERAL (SIDEBAR) */}
      <aside className="w-64 bg-slate-50 dark:bg-slate-950 flex flex-col border-r border-slate-200 dark:border-slate-800 shrink-0">
        <div className="p-6 border-b border-slate-200 dark:border-slate-800">
          <h2 className="text-xl font-black italic tracking-tighter bg-gradient-to-br from-blue-500 to-emerald-400 bg-clip-text text-transparent">
            NEXA-AI
          </h2>
          <p className="text-[10px] font-bold text-slate-400 dark:text-slate-500 mt-1 tracking-[0.2em]">CONVERSANDO EL FUTURO</p>
        </div>

        <nav className="flex-1 px-4 py-6 space-y-8 overflow-y-auto">
          <div>
            <p className="text-[10px] text-slate-400 dark:text-slate-600 font-black mb-4 px-2 tracking-widest">RECURSOS</p>
            <div className="space-y-1">
              <button className="w-full text-left text-xs p-2.5 rounded-lg hover:bg-white dark:hover:bg-slate-900 transition-all text-slate-600 dark:text-slate-300 font-medium">
                Políticas AWS
              </button>
              <button className="w-full text-left text-xs p-2.5 rounded-lg hover:bg-white dark:hover:bg-slate-900 transition-all text-slate-600 dark:text-slate-300 font-medium">
                Documentación S3
              </button>
            </div>
          </div>

          <div>
            <p className="text-[10px] text-slate-400 dark:text-slate-600 font-black mb-4 px-2 tracking-widest">HISTORIAL</p>
            <div className="space-y-1">
              {historial.map((h, i) => (
                <div key={i} className="text-[11px] p-2.5 rounded-lg text-slate-500 dark:text-slate-400 hover:bg-white dark:hover:bg-blue-950/30 truncate cursor-pointer transition-all">
                  {h}
                </div>
              ))}
            </div>
          </div>
        </nav>

        <div className="p-4 border-t border-slate-200 dark:border-slate-800">
          <button 
            onClick={() => setDarkMode(!darkMode)}
            className="w-full py-3 rounded-xl bg-slate-900 dark:bg-blue-600 text-white text-[10px] font-black tracking-widest transition-all active:scale-95 shadow-md"
          >
            {darkMode ? "MODO CLARO" : "MODO OSCURO"}
          </button>
        </div>
      </aside>

      {/* 2. ÁREA PRINCIPAL (CHATS Y ENTRADA) */}
      <div className="flex-1 flex flex-col bg-white dark:bg-black relative">
        
        {/* Header Superior Centrado */}
        <header className="px-8 py-4 flex justify-center items-center border-b border-slate-100 dark:border-slate-800">
          <h1 className="text-[10px] font-black dark:text-white uppercase tracking-[0.3em] opacity-50">ASISTENTE INTELIGENTE</h1>
        </header>

        {/* Chat de Pantalla Completa con Scroll */}
        <section className="flex-1 overflow-y-auto px-8 md:px-24 py-8 space-y-8 bg-white dark:bg-black">
          {chats.map((chat, index) => (
            <div key={index} className={`flex ${chat.rol === "user" ? "justify-end" : "justify-start"}`}>
              <div className={`
                relative p-[1.5px] rounded-2xl max-w-[85%] shadow-sm transition-all
                ${chat.rol === "bot" ? "bg-multi-color animate-gradient-xy" : "bg-slate-100 dark:bg-slate-800"}
              `}>
                
                {/* Contenedor interno con control de color para evitar el bloque blanco en modo oscuro */}
                <div className={`p-4 rounded-[14.5px] ${
                  chat.rol === "bot" 
                    ? "bg-white dark:bg-zinc-950 text-slate-800 dark:text-slate-100" 
                    : "text-slate-800 dark:text-slate-100"
                }`}>
                  <p className="text-sm font-medium leading-relaxed">
                    {chat.contenido}
                  </p>
                </div>

              </div>
            </div>
          ))}
        </section>

        {/* Footer con Barra de Entrada Premium */}
        <footer className="p-8 bg-white dark:bg-black">
          <div className="max-w-4xl mx-auto flex items-center gap-3 p-2.5 rounded-2xl border border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-900/50 transition-all focus-within:border-blue-500 shadow-sm">
            
            {/* BOTÓN MICRÓFONO CON ANIMACIÓN GRADIENTE ACTIVA */}
            <button 
              onClick={() => setIsRecording(!isRecording)}
              className={`p-3 rounded-xl transition-all ${
                isRecording 
                  ? "bg-multi-color animate-gradient-xy text-white shadow-lg scale-105" 
                  : "text-slate-400 hover:text-slate-600 dark:hover:text-slate-200"
              }`}
              title={isRecording ? "Detener grabación" : "Grabar voz"}
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                <path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z"/>
                <path d="M19 10v2a7 7 0 0 1-14 0v-2"/>
                <line x1="12" x2="12" y1="19" y2="22"/>
              </svg>
            </button>

            {/* CAMPO DE ENTRADA DE TEXTO */}
            <input 
              type="text" 
              placeholder={isRecording ? "Escuchando..." : "Escribe tu consulta..."}
              className="flex-1 bg-transparent p-2 outline-none text-xs font-bold dark:text-white placeholder:text-slate-400"
              value={mensaje}
              onChange={(e) => setMensaje(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && enviarMensaje()}
            />
            
            {/* BOTÓN DE ENVÍO */}
            <button 
              onClick={enviarMensaje} 
              className="bg-slate-900 dark:bg-blue-600 text-white p-3 rounded-xl hover:bg-blue-700 dark:hover:bg-blue-500 transition-all active:scale-90 shadow-lg"
              title="Enviar mensaje"
            >
              <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                <path d="m5 12 7-7 7 7"/><path d="M12 19V5"/>
              </svg>
            </button>
          </div>

          {/* TU NUEVO LEMA DE MARCA PREMIUM */}
          <p className="text-[9px] text-center mt-4 text-slate-80 dark:text-slate-300 font-bold tracking-[0.5em] uppercase opacity-80">
            Nexa-AI BeTek V.2.0
          </p>
        </footer>
      </div>

      {/* INYECCIÓN DE ESTILOS CSS PARA LA ANIMACIÓN MULTICOLOR */}
      <style jsx global>{`
        @keyframes gradient-xy {
          0% { background-position: 0% 50%; }
          50% { background-position: 100% 50%; }
          100% { background-position: 0% 50%; }
        }
        .bg-multi-color {
          background: linear-gradient(45deg, #3b82f6, #a855f7, #10b981, #facc15);
          background-size: 400% 400%;
        }
        .animate-gradient-xy {
          animation: gradient-xy 4s ease infinite;
        }
      `}</style>
    </main>
  );
}