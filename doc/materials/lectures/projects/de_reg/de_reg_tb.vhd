library ieee;                                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;                                        -- dolaczenie calego pakietu 'STD_LOGIC_MISC'
use     work.sim_lib.all;                                               -- dolaczenie calego pakietu wlasnego 'SIM_LIB'

entity DE_REG_TB is                                                     -- sprzeg projektu symulacji 'DE_REG_TB'
  generic(                                                              -- deklaracja parametrow
    WIDTH                :integer := 4);                                -- ustalenie rozmiaru danych 'WIDTH'
end DE_REG_TB;                                                         -- zakonczenie deklaracji sprzegu

architecture cialo of DE_REG_TB is                                      -- deklaracja architektury 'cialo' dla sprzegu 'DE_REG_TB'
  signal R, S, L, C, E          :std_logic := '0';                                      -- symulacja sygnalow 'R', 'S', 'L', 'C', 'E'
  signal V, D                   :std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- symulacja sygnalow 'V', 'D'
  signal sQ, aQ, tQ             :std_logic_vector(WIDTH-1 downto 0) := (others => '0'); -- obserwacja sygnalow 'sQ', 'aQ', 'tQ'
  signal sE, aE, eE             :std_logic := '0';                                      -- obserwacja bledow 'sE', 'aE', 'eE'
begin                                                                   -- czesc wykonawcza architektury 'cialo'
  process is                                                            -- proces bezwarunkowy
    variable cR,cS,cL,cV,cC,cE,cD :integer := 0;                        -- wartosci licznikow krokow dla sygnalow symulowanych
    variable b                    :boolean;                             -- stab blokady zmiany sygnalu w celu unikniecia hazardu
  begin                                                                 -- czesc wykonawcza procesu
    loop                                                                -- petla nieskonczona
      sim_ctrl_tst(10 ns, 10 ns,  b, eE);                               -- sterowanie krokami symulacji przez funkcje 'sim_ctrl_tst'
      sim_ctrl_sig(  50, 50,  cC, b, C);                                -- sterowanie sygnalem 'C' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(2000,200,  cR, b, R);                                -- sterowanie sygnalem 'R' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(1700,170,  cS, b, S);                                -- sterowanie sygnalem 'S' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(2000,500,  cL, b, L);                                -- sterowanie sygnalem 'L' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(  30, 30,1,cV, b, V);                                -- sterowanie wektorem 'V' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig( 200,400,  cE, b, E);                                -- sterowanie sygnalem 'E' przez funkcje 'sim_ctrl_sig'
      sim_ctrl_sig(  20, 20,3,cD, b, D);                                -- sterowanie wektorem 'D' przez funkcje 'sim_ctrl_sig'
    end loop;                                                           -- zakonczenie cyklu petli
  end process;                                                          -- zakonczenie procesu

  impl: entity work.DE_REG_IMPL4 port map (R,S,L,V,C,E,D,sQ,R,S,L,V,C,E,D,aQ); -- instacja projektu 'DE_REG_IMPL4'
  
  process (R, S, L, V, C) is begin                                      -- lista czulosci procesu
    if    (R='1') then  tQ <= (others => '0');                          -- kasowanie 'tQ' dla 'R' rownego '1'
    elsif (S='1') then  tQ <= (others => '1');                          -- alteratywne ustawienie 'tQ' gdy 'S' jest rowne '1'
    elsif (L='1') then  tQ <= V;                                        -- alteratywne przypisanie 'V' do 'tQ' gdy  'L' jest rowne '1'
    elsif (C'event) then                                                -- alteratywne badanie, czy wystapilo zbocze na sygnale 'C' 
      if (E='1') then  tQ <= D; end if;                                 -- jesli tak, przypisanie 'D' do 'tQ' gdy 'E' jest rownego '1'
    end if;                                                             -- zakonczenie wielokrotnych warunkow 
  end process;                                                          -- zakonczenie procesu

  sE <= transport eE and OR_REDUCE(sQ xor tQ) after 1ps;                -- testowanie zgodnosci stanow sygnalow 'sQ' i 'tQ'
  aE <= transport eE and OR_REDUCE(aQ xor tQ) after 1ps;                -- testowanie zgodnosci stanow sygnalow 'aQ' i 'tQ'
end architecture cialo;                                                 -- zakonczenie architektury 'cialo'
