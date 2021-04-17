library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;                                    -- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

entity DE_MAX_SIM_TB is                                                 -- sprzeg projektu symulacji 'DE_MAX_SIM_TB'
  generic(                                                              -- deklaracja parametrow
    PROBE_ns		:real    := 20.0;                               -- ustalenie czasu probkowania 'PROBE_ns' w [ns]                                
    TSIN1_ns		:real    := 50000.0;                            -- ustalenie okresu 'TSIN1_ns' okresu sinusoidy 1 w [ns] 
    TSIN2_ns	        :real    := 1700.0;                             -- ustalenie okresu 'TSIN2_ns' okresu sinusoidy 2 w [ns] 
    WIDTH		:natural := 8                                   -- ustalenie rozmiaru danych 'WIDTH'
  );                                                                    -- zakonczenie deklaracji parametrow
end DE_MAX_SIM_TB;                                                      -- zakonczenie deklaracji sprzegu

architecture cialo of DE_MAX_SIM_TB is                                  -- deklaracja architektury 'cialo' dla sprzegu 'DE_MAX_SIM_TB'
  signal R, S, L, C, E :std_logic := '0';                               -- symulacja bitow wejsciowych 'R', 'S', 'L', 'C', 'E'
  signal V, D  :std_logic_vector(WIDTH-1 downto 0) := (others => '0');  -- symulacja wektorow wejsciowych 'V', 'D'
  signal M     :std_logic_vector(WIDTH-1 downto 0);                     -- obserwacja wektora wyjsciowego 'M'
begin                                                                   -- czesc wykonawcza architektury 'cialo'
  process is begin                                                      -- proces bezwarunkowy
    C <= '1'; wait for PROBE_ns*1ns;                                    -- ustawienie 'C' na '1' i odczekanie czasu 'PROBE_ns' w [ns]
    C <= '0'; wait for PROBE_ns*1ns;                                    -- ustawienie 'C' na '0' i odczekanie czasu 'PROBE_ns' w [ns]
  end process;                                                          -- zakonczenie procesu

  process is                                                            -- proces bezwarunkowy
    function sin1(a1: real) return real is                              -- deklaracja wewnetrznej funkcji 'sin1'
      constant val :real_vector := (                                    -- deklaracja 100 wartosci dla jednego okresu funkcji 'sinus'
        0.000000,0.062791,0.125333,0.187381,0.248690,0.309017,0.368125,0.425779,0.481754,0.535827,0.587785,0.637424,0.684547,0.728969,0.770513,0.809017,0.844328,
        0.876307,0.904827,0.929776,0.951057,0.968583,0.982287,0.992115,0.998027,1.000000,0.998027,0.992115,0.982287,0.968583,0.951057,0.929776,0.904827,0.876307,
        0.844328,0.809017,0.770513,0.728969,0.684547,0.637424,0.587785,0.535827,0.481754,0.425779,0.368125,0.309017,0.248690,0.187381,0.125333,0.062791,0.000000,
        -0.062791,-0.125333,-0.187381,-0.248690,-0.309017,-0.368125,-0.425779,-0.481754,-0.535827,-0.587785,-0.637424,-0.684547,-0.728969,-0.770513,-0.809017,
        -0.844328,-0.876307,-0.904827,-0.929776,-0.951057,-0.968583,-0.982287,-0.992115,-0.998027,-1.000000,-0.998027,-0.992115,-0.982287,-0.968583,-0.951057,
        -0.929776,-0.904827,-0.876307,-0.844328,-0.809017,-0.770513,-0.728969,-0.684547,-0.637424,-0.587785,-0.535827,-0.481754,-0.425779,-0.368125,-0.309017,
        -0.248690,-0.187381,-0.125333,-0.062791);
    begin                                                               -- czesc wykonawcza funkcji
      return(val(integer(a1*100.0) mod 100));                           -- zwrocenie wartosci 'sinus' dla argumentu 'a1' w umownym okresie <0:1)
    end function;                                                       -- zakonczenie deklaracji funcji
    variable a1, a2 :real;                                              -- zmienne dla wartosci dwoch funkcji sinus
    constant Z :std_logic_vector(WIDTH-1 downto 0) := (others => '0');  -- stala dla wartosc 0 wektora
  begin                                                                 -- czesc wykonawcza procesu
    R <= '0'; S <= '0'; L <= '0';  E <= '1';                            -- przypisanie wartosci sygnalow 'R', 'S', 'L' na '0' i 'E' na '1'
    V <= (others => '0'); D <= (others => '0');                         -- przypisanie wartosci sygnalow wektorowych 'V' i 'D' na 0
                         wait for PROBE_ns/2*1ns;                       -- odczekanie 1/2 okresu 'PROBE_ns' w [ns]
    D <= D+13; R <= '1'; wait for PROBE_ns*1ns;                         -- zwiekszenie D o 13, ustawienie 'R' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    R <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'R' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    S <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'S' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    S <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'S' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    V <= V+13;           wait for PROBE_ns*1ns;                         -- zwiekszenie V o 13 i odczekanie okresu 'PROBE_ns' w [ns]
    for t in 1 to 2000 loop                                             -- wykonanie 2000 cykli petli indeksowanej przez 't'
      a1 := sin1((real(t)*PROBE_ns)/TSIN1_ns);                          -- przypisanie 'a1' wartosci 'sinus' o okresie 'TSIN1_ns' dla czasu 't*PROBE_ns'
      a2 := sin1((real(t)*PROBE_ns)/TSIN2_ns);                          -- przypisanie 'a2' wartosci 'sinus' o okresie 'TSIN2_ns' dla czasu 't*PROBE_ns'
      D  <= Z+integer(100.0*(a1*a2+1.1));                               -- przypisanie 'D' wartosci modulacja sygnalami sinusoidalnymi 
      wait for PROBE_ns*1ns;                                            -- odczekanie okresu 'PROBE_ns' w [ns]
    end loop;                                                           -- zakonczenie cyklu petli
    L <= '1';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '1' i odczekanie okresu 'PROBE_ns' w [ns]
    L <= '0';            wait for PROBE_ns*1ns;                         -- ustawienie 'L' na '0' i odczekanie okresu 'PROBE_ns' w [ns]
    wait;                                                               -- zatrzymanie wykonywania procesu do konca ymulacji
  end process;                                                          -- zakonczenie procesu

  de_max_inst: entity work.DE_MAX_SIM generic map(WIDTH) port map(R, S, L, V, C, E, D, M); -- instacja projektu 'DE_MAX_SIM'

end cialo;                                                              -- zakonczenie ciala architektonicznego
