library ieee;
use     ieee.std_logic_1164.all;

entity DE_REG_SIM is                                     -- pusty sprzeg projektu symulacji
  generic(
    WIDTH       :integer := 8
  );
  port(
    R           :in  std_logic := '0';
    S           :in  std_logic := '0';
    L           :in  std_logic := '0';
    V           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    C           :in  std_logic := '0';
    E           :in  std_logic := '1';
    D           :in  std_logic_vector(WIDTH-1 downto 0) := (others => '0');
    Q           :out std_logic_vector(WIDTH-1 downto 0)
  );
end DE_REG_SIM;

architecture behavioural of DE_REG_SIM is                -- cialo architektoniczne projektu
begin
  process(R, S, L, V, C) is begin
    if (R='1') then
      Q <= (others => '0');
    elsif (S='1') then
      Q <= (others => '1');
    elsif (L='1') then
      Q <= V;
    elsif (C'event) then
      if (E='1') then
        Q <= D;
      end if;
    end if; 
  end process;
end behavioural;                                        -- zakonczenie ciala architektonicznego
