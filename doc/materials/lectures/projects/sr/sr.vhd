library ieee;                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity SR_SYNC is                               -- deklaracja sprzegu 'SR_SYNC'
  port(                                         -- deklaracja portow
    R                   :in  std_logic;         -- deklaracja kasujacego portu wejsciowego 'R'
    S			:in  std_logic;         -- deklaracja ustawiajacego portu wejsciowego 'S'
    Q			:out std_logic          -- deklaracja portu wyjsciowego stanu 'Q'
  );
end SR_SYNC;                                    -- zakonczenie deklaracji sprzegu

architecture cialo of SR_SYNC is		-- deklaracja architektury 'cialo' dla sprzegu 'SR_SYNC'
  signal   Qres		:std_logic;             -- deklaracja sygnalu kasowania asynchonicznego 'Qres'
  signal   Qset		:std_logic;             -- deklaracja sygnalu ustawiania synchronicznego 'Qset'
  signal   Qreg		:std_logic := '0';      -- deklaracja sygnalu stanu przerzutnika 'Qreg'
begin
  Qres <= R and Qreg;                           -- asynchroniczne przypisanie wyrazenia do sygnalu 'Qres' 
  Qset <= S and not(R);                         -- asynchroniczne przypisanie wyrazenia do sygnalu 'Qset'

  process (Qres, Qset) is begin                 -- lista czulosci procesu
    if (Qres='1') then                          -- badanie, czy sygnal 'Qres' ma wartosc '1'
      Qreg <='0';                               -- jezeli tak, asynchroniczne ustawienie 'Qreg' na wartosc '0'
    elsif(Qset'event and Qset='1') then         -- alternatywne badanie, czy wystapilo zbocze narastajace na sygnale 'Qset'
      Qreg <='1';                               -- jezeli tak, synchroniczne ustawienie 'Qreg' na wartosc '1'
    end if;                                     -- zakonczenie warunku
  end process;                                  -- zakonczenie procesu

  Q <= Qreg;                                    -- asynchroniczne sygnalu 'Qreg' do portu wyjsciowego 'Q'
end architecture cialo;                         -- zakonczenie architektury 'cialo'			   

----------------------------------------------------------------------------------------------------------------

library ieee;                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                -- dolaczenie calego pakietu 'STD_LOGIC_1164'
  
entity SR_ASYNC is                              -- deklaracja sprzegu 'SR_ASYNC'
  port(                                         -- deklaracja portow
    R                   :in  std_logic;         -- deklaracja kasujacego portu wejsciowego 'R'
    S			:in  std_logic;         -- deklaracja ustawiajacego portu wejsciowego 'S'
    Q			:out std_logic          -- deklaracja portu wyjsciowego stanu 'Q'
  );
end SR_ASYNC;                                   -- zakonczenie deklaracji sprzegu

architecture cialo of SR_ASYNC is begin  	-- deklaracja architektury 'cialo' dla sprzegu 'SR_ASYNC'
  process (R, S) is begin                       -- lista czulosci procesu
    if (R='1') then                             -- badanie, czy sygnal 'R' ma wartosc '1'
      Q <= '0';                                 -- jezeli tak, asynchroniczne ustawienie 'Q' na wartosc '0'
    elsif (S='1') then                          -- alternatywne badanie, czy sygnal 'S' ma wartosc '1'
      Q <= '1';                                 -- jezeli tak, asynchroniczne ustawienie 'Q' na wartosc '1'
    end if;                                     -- zakonczenie warunku
  end process;                                  -- zakonczenie procesu
end architecture cialo;                         -- zakonczenie architektury 'cialo'				   

----------------------------------------------------------------------------------------------------------------

library ieee;                                   -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                -- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity SR_IMPL is
  port(
    sR                  :in  std_logic;         -- deklaracja kasujacego portu wejsciowego 'sR' dla projetu 'SR_SYNC'
    sS                  :in  std_logic;         -- deklaracja ustawiajacego portu wejsciowego 'sS' dla projetu 'SR_SYNC'
    sQ                  :out std_logic;         -- deklaracja portu wyjsciowego stanu 'sQ' dla projetu 'SR_SYNC'
    aR                  :in  std_logic;         -- deklaracja kasujacego portu wejsciowego 'aR' dla projetu 'SR_ASYNC'
    aS                  :in  std_logic;         -- deklaracja ustawiajacego portu wejsciowego 'aS' dla projetu 'SR_ASYNC'
    aQ                  :out std_logic          -- deklaracja portu wyjsciowego stanu 'aQ' dla projetu 'SR_ASYNC'
  );
end SR_IMPL
;
architecture cialo of SR_IMPL is begin          -- deklaracja architektury 'cialo' dla sprzegu 'SR_IMPL'
   syn: entity work.SR_SYNC  port map (sR,  sS,  sQ); -- instancja projetu 'SR_SYNC'
  asyn: entity work.SR_ASYNC port map (aR,  aS,  aQ); -- instancja projetu 'SR_ASYNC'
end architecture cialo;                         -- zakonczenie architektury 'cialo'				   
