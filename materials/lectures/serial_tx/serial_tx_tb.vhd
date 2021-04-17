library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

entity SERIAL_TX_TB is
  generic (
    F_ZEGARA		:natural := 20000000;
    L_MIN_BODOW		:natural := 110;
    L_BODOW		:natural := 2000000;
    B_SLOWA		:natural := 8;
    B_PARZYSTOSCI	:natural := 1;
    B_STOPOW		:natural := 2;
    N_TX		:boolean := FALSE;
    N_SLOWO		:boolean := FALSE
  );
end SERIAL_TX_TB;

architecture behavioural of SERIAL_TX_TB is

  signal   R		:std_logic;
  signal   C		:std_logic;
  signal   TXO,TX	:std_logic;
  signal   SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);
  signal   NADAJ	:std_logic;
  signal   WYSYLANIE	:std_logic;

  signal   ODEBRANO	:std_logic_vector(B_SLOWA-1 downto 0);

  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;
  
begin

  process is
  begin
    C <= '1';
    wait for O_ZEGARA/2;
    C <= '0';
    wait for O_ZEGARA/2;
  end process;
  
  process is
  begin
    R      <= '1';
    NADAJ  <= '0';
    SLOWO  <= (others=>'0');
    wait for 5.5*O_ZEGARA;
    R <= '0';
    loop
      wait for 5*O_ZEGARA;
      NADAJ  <= '1';
      wait for O_ZEGARA;
      NADAJ  <= '0';
      wait for O_ZEGARA;
      wait until WYSYLANIE='0';
      SLOWO <= SLOWO + 7;
      wait for 10.5*O_ZEGARA;
    end loop;
  end process;
  
  serial_tx_inst: entity work.SERIAL_TX(behavioural)
    generic map (
      F_ZEGARA      => F_ZEGARA,
      L_MIN_BODOW   => L_MIN_BODOW,
      B_SLOWA       => B_SLOWA,
      B_PARZYSTOSCI => B_PARZYSTOSCI,
      B_STOPOW      => B_STOPOW,
      N_TX          => N_TX,
      N_SLOWO       => N_SLOWO
    )
    port map (
      R             => R,
      C             => C,
      T_BODU	    => F_ZEGARA/L_BODOW,
      TX            => TXO,
      SLOWO         => SLOWO,
      NADAJ         => NADAJ,
      WYSYLANIE     => WYSYLANIE
   );

  TX <= TXO when N_TX=FALSE else not(TXO);

  process is
    constant O_BITU :time := 1 sec/L_BODOW;
    variable blad   : boolean;
  begin
    ODEBRANO <= (others => '0');
    loop
      blad := FALSE;
      wait until TX='1';
      wait for O_BITU/2;
      if (TX /= '1') then
        blad := TRUE;
      end if;
      wait for O_BITU;
      for i in 0 to B_SLOWA-1 loop
        ODEBRANO(ODEBRANO'left-1 downto 0) <= ODEBRANO(ODEBRANO'left downto 1);
        ODEBRANO(ODEBRANO'left) <= TX;
        wait for O_BITU;
      end loop;
      if (B_PARZYSTOSCI = 1) then
        if (TX /= XOR_REDUCE(SLOWO)) then
          blad := TRUE;
        end if;
        wait for O_BITU;
      end if;
      for i in 0 to B_STOPOW-1 loop
        if (TX /= '0') then
          blad := TRUE;
        end if;
      end loop;
      if (blad=TRUE) then
        ODEBRANO <= (others => 'X');
      elsif (N_SLOWO=TRUE) then
        ODEBRANO <= not(ODEBRANO);
      end if;
    end loop;
  end process;

end behavioural;

