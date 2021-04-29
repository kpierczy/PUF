library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;

entity ASSERT_DEMULTIPL1_TB is
  generic (
    X_SZEROKOSC		:natural := 4;				-- szerokosci slowa 'X'
    Y_SZEROKOSC		:natural := 16				-- szerokosci slowa 'Y'
  );
end ASSERT_DEMULTIPL1_TB;

architecture behavioural of ASSERT_DEMULTIPL1_TB is

  signal X :std_logic_vector (X_SZEROKOSC-1 downto 0);		-- sterowanie portem wejsciowym 'X'
  signal I :natural;						-- sterowanie portem wejsciowym 'I'
  signal Y :std_logic_vector (Y_SZEROKOSC-1 downto 0);		-- monitorowanie portu wyjsciowego 'Y'
	
begin

 process is
  begin
    for k in 0 to 10 loop
      I  <= k;
      X  <= CONV_STD_LOGIC_VECTOR(k+1,X'length);
      wait for 10ns;
    end loop;
    wait;
  end process;

  assert_demultipl1_inst: entity work.ASSERT_DEMULTIPL1(cialo)
   generic map (
     X_SZEROKOSC => X_SZEROKOSC,
     Y_SZEROKOSC => Y_SZEROKOSC
   )
   port map (
      X  => X,
      I  => I,
      Y  => Y
    );

end behavioural;

---------------------------------------------------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.std_logic_arith.all;

entity ASSERT_DEMULTIPL2_TB is
  generic (
    X_SZEROKOSC		:natural := 4;				-- szerokosci slowa 'X'
    Y_SZEROKOSC		:natural := 16				-- szerokosci slowa 'Y'
  );
end ASSERT_DEMULTIPL2_TB;

architecture behavioural of ASSERT_DEMULTIPL2_TB is

  signal X :std_logic_vector (X_SZEROKOSC-1 downto 0);		-- sterowanie portem wejsciowym 'X'
  signal I :natural;						-- sterowanie portem wejsciowym 'I'
  signal Y :std_logic_vector (Y_SZEROKOSC-1 downto 0);		-- monitorowanie portu wyjsciowego 'Y'
	
begin

 process is
  begin
    for k in 0 to 10 loop
      I  <= k;
      X  <= CONV_STD_LOGIC_VECTOR(k+1,X'length);
      wait for 10ns;
    end loop;
    wait;
  end process;

  assert_demultipl2_inst: entity work.ASSERT_DEMULTIPL2(cialo)
   generic map (
     X_SZEROKOSC => X_SZEROKOSC,
     Y_SZEROKOSC => Y_SZEROKOSC
   )
   port map (
      X  => X,
      I  => I,
      Y  => Y
    );

end behavioural;
