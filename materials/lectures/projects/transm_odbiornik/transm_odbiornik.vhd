library ieee;                                           -- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;                        -- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     work.transm_lib.all;                            -- dolaczenie calego pakietu uzykownika 'TRANS_LIB'

entity TRANSM_ODBIORNIK is                              -- deklaracja sprzegu 'TRANSM_ODBIORNIK'
  generic(                                              -- deklaracja parametrow
    C_MULT       :integer := 8                          -- deklaracja parametru zwielokrotnienia 'C_MULT'
  );                                                    -- zakonczenie deklaracji parametrow
  port(                                                 -- deklaracja portow
    R           :in  std_logic;                         -- deklaracja kasujacego portu wejsciowego 'R'
    C           :in  std_logic;                         -- deklaracja portu wejsciowego zegara 'C'
    MC          :in  std_logic;                         -- deklaracja portu wejsciowego zegara zwielokrotnionego 'MC'
    RX          :in  std_logic;                         -- deklaracja portu wejsciowego sygnalu nadawania 'TX'
    OB          :in  integer range 0 to C_MULT-1;       -- deklaracje portu wejsciowego wartosci opoznienia 'OB'
    T           :in  std_logic;                         -- deklaracja portu wejsciowego trybu testowego 'T'
    D           :out std_logic_vector(C_MULT-1 downto 0); -- deklaracja portu wyjsciowego danych 'D'
    S           :out std_logic                          -- deklaracja portu wyjsciowego synchronizacji odbiornika
  );                                                    -- zakonczenie deklaracja portow
end entity TRANSM_ODBIORNIK;                            -- zakonczenie deklaracji sprzegu

architecture cialo of TRANSM_ODBIORNIK is	        -- deklaracja architektury 'cialo' dla sprzegu 'TRANSM_ODBIORNIK'  
  signal OBUF, DBUF, DREG :std_logic_vector(C_MULT-1 downto 0); -- deklaracje buforow
begin						        -- poczatek czesci wykonawczej architektury

  process (R, MC) is begin                              -- lista czulosci procesu
    if (R='1') then                                     -- badanie, czy sygnal 'R' ma wartosc '1'
      OBUF <= (others => '0');                          -- jeœli tak, asynch. ustaw. bity wektora 'OBUF' na wartosc '0'
      DBUF <= (others => '0');                          -- jeœli tak, asynch. ustaw. bity wektora 'DBUF' na wartosc '0'
    elsif (MC'event and MC='1') then                    -- alternatywne badanie, czy wystapilo zbocze narastajace 'MC'
      OBUF(0) <= RX;                                    -- jeœli tak, synch. przypisanie '0' do bitu 'OBUF(0)'
      OBUF(C_MULT-1 downto 1) <= OBUF(C_MULT-2 downto 0); -- jeœli tak, synch. przesuniêcie w lewo bitow wektora 'OBUF'
      DBUF(0) <= OBUF(OB);                              -- jeœli tak, synch. przypisanie '0' do bitu 'DBUF(0)'
      DBUF(C_MULT-1 downto 1) <= DBUF(C_MULT-2 downto 0); -- jeœli tak, synch. przesuniêcie w lewo bitow wektora 'DBUF'
    end if;                                             -- zakonczenie wielokrotnych warunkow 
  end process;                                          -- zakonczenie procesu

  process (R, C) is begin                               -- lista czulosci procesu
    if (R='1') then                                     -- badanie, czy sygnal 'R' ma wartosc '1'
      DREG <= (others => '0');                          -- jeœli tak, asynch. ustaw. bity wektora 'D' na wartosc '0'
      D    <= (others => '0');                          -- jeœli tak, asynch. ustaw. bity wektora 'D' na wartosc '0'
      S    <= '0';                                      -- jeœli tak, synch. przypisanie do '0' do 'S'
    elsif (C'event and C='1') then                      -- alternatywne badanie, czy wystapilo zbocze narastajace 'C'
      DREG <= DBUF;                                     -- jeœli tak, synch. przypisanie do 'DBUF' do 'DREG'
      D    <= (others => '0');                          -- jeœli tak, asynch. ustaw. bity wektora 'D' na wartosc '0'
      S    <= '0';                                      -- jeœli tak, synch. przypisanie do '0' do 'S'
      if (T='1') then                                   -- jeœli tak, badanie trybu testowego nadawania
        if (RndGet(DREG)=DBUF) then S <= '1'; end if;   -- jeœli poprawny tryb testowy, synch. ustaw. stanu bitu 'S' na '1'
      else                                              -- jesli tak, wybor warunku nadawania danych
        D <= DBUF;                                      -- jeœli tryb nadawania, synch. przypusanie wektora 'DBUF' na port 'D'
      end if;                                           -- zakonczenie badania warunkow trybu nadawania
    end if;                                             -- zakonczenie wielokrotnych warunkow 
  end process;                                          -- zakonczenie procesu

end architecture cialo;                                 -- zakonczenie architektury 'cialo'