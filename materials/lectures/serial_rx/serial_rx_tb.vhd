library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_unsigned.all;
use     ieee.std_logic_misc.all;

entity SERIAL_RX_TB is
  generic (
    F_ZEGARA		:natural := 20000000;
    L_MIN_BODOW		:natural := 110;
    L_BODOW		:natural := 2000000;
    B_SLOWA		:natural := 8;
    B_PARZYSTOSCI	:natural := 1;
    B_STOPOW		:natural := 2;
    N_RX		:boolean := FALSE;
    N_SLOWO		:boolean := FALSE
  );
end SERIAL_RX_TB;

architecture behavioural of SERIAL_RX_TB is

  signal   R		:std_logic;
  signal   C		:std_logic;
  signal   RX		:std_logic;
  signal   SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);
  signal   GOTOWE	:std_logic;
  signal   BLAD		:std_logic;
  
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;
  constant O_BITU	:time := 1 sec/L_BODOW;
  signal   D		:std_logic_vector(SLOWO'range);
  
begin

  process is
  begin
    C <= '0';
    wait for O_ZEGARA/2;
    C <= '1';
    wait for O_ZEGARA/2;
  end process;
  
  process is
  begin
    wait for O_ZEGARA;
    R  <= '1';
    RX <= '0';
    D  <= (others=>'0');
    wait for 2*O_ZEGARA;
    R <= '0';
    wait for 10*O_ZEGARA;
    loop
      RX <= '1';
      wait for O_BITU;
      for i in 0 to B_SLOWA-1 loop
        RX <= D(i);
        wait for O_BITU;
      end loop;
      if (B_PARZYSTOSCI = 1) then
        RX <= XOR_REDUCE(D);
        wait for O_BITU;
      end if;
      for i in 0 to B_STOPOW-1 loop
        RX <= '0';
        wait for O_BITU;
      end loop;
      D <= D + 7;
      wait for 10*O_ZEGARA  	;
    end loop;
  end process;
  
  serial_rx_inst: entity work.SERIAL_RX(behavioural)
    generic map (
      F_ZEGARA      => F_ZEGARA,
      L_MIN_BODOW   => L_MIN_BODOW,
      B_SLOWA       => B_SLOWA,
      B_PARZYSTOSCI => B_PARZYSTOSCI,
      B_STOPOW      => B_STOPOW,
      N_RX          => N_RX,
      N_SLOWO       => N_SLOWO
    )
    port map (
      R             => R,
      C             => C,
      T_BODU        => F_ZEGARA/L_BODOW,
      RX            => RX,
      SLOWO         => SLOWO,
      GOTOWE        => GOTOWE,
      BLAD          => BLAD
   );

end behavioural;

