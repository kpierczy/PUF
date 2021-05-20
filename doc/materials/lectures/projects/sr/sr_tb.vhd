library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     work.sim_lib.all;                                               -- dolaczenie calego pakietu wlasnego 'SIM_LIB'

entity SR_TB is                                                         -- pusty sprzeg projektu symulacji 'SR_TB'
end SR_TB;                                                              -- zakonczenie deklaracji sprzegu

architecture cialo of SR_TB is		                                -- deklaracja architektury 'cialo' dla sprzegu 'SR_TB'

  signal R, S			:std_logic := '0';                      -- symulacja bitow wejsciowych 'R', 'S'
  signal sQ, aQ, tQ	        :std_logic := '0';                      -- obserwacja bitow wyjsciowych 'sQ', 'aQ', 'tQ'
  signal sE, aE, eE             :std_logic;                             -- obserwacja bitow bledow 'sE', 'aE', 'eE'

begin						                        -- poczatek czesci wykonawczej architektury

  process is                                                            -- proces bezwarunkowy
    variable cR, cS             :integer := 0;                          -- wartosci licznikow krokow dla sygnalow 'R' i 'S'
    variable b                  :boolean;                               -- stab blokady zmiany sygnalu w celu unikniecia hazardu
  begin                                                                 -- czesc wykonawcza procesu
    loop                                                                -- petla nieskonczona
      sim_ctrl_tst(10 ns, 10 ns, b, eE);                                -- sterowanie krokami symulacji przez funkcje 'sim_ctrl_tst'
      sim_ctrl_sig(5,6,cR,b,R);                                         -- sterowanie sygnalem 'R' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(4,3,cS,b,S);                                         -- sterowanie sygnalem 'S' przez funkcje 'sim_ctrl_sig'
    end loop;                                                           -- zakonczenie cyklu petli
  end process;                                                          -- zakonczenie procesu

  impl: entity work.SR_IMPL  port map (R,  S, sQ,  R, S, aQ);           -- instancja projektu 'SR_IMPL'

  process (R, S) is begin                                               -- lista czulosci procesu
    if (R='1') then                                                     -- badanie, czy sygnal 'R' ma wartosc '1'
      tQ <= '0';                                                        -- jeœli tak, asynchroniczne ustawienie 'tQ' na wartosc '0'
    elsif (S='1') then                                                  -- alternatywne badanie, czy sygnal 'S' ma wartosc '1'
      tQ <= '1';                                                        -- jeœli tak, asynchroniczne ustawienie 'tQ' na wartosc '1'
    end if;                                                             -- zakonczenie warunku
  end process;                                                          -- zakonczenie procesu
 
  sE <= transport eE and (sQ xor tQ) after 1ps;                         -- testowanie zgodnosci stanow sygnalow 'sQ' i 'tQ'
  aE <= transport eE and (aQ xor tQ) after 1ps;                         -- testowanie zgodnosci stanow sygnalow 'aQ' i 'tQ'
      
end architecture cialo;                                                 -- zakonczenie ciala architektonicznego
