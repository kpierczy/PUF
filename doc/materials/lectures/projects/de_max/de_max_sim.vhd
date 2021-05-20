library ieee;
use     ieee.std_logic_1164.all;

entity DE_MAX_SIM is                                     -- pusty sprzeg projektu symulacji
  generic(
    WIDTH       :integer := 8
  );
  port(
    R           :in  std_logic;
    S           :in  std_logic;
    L           :in  std_logic;
    V           :in  std_logic_vector(WIDTH-1 downto 0);
    C           :in  std_logic;
    E           :in  std_logic;
    D           :in  std_logic_vector(WIDTH-1 downto 0);
    M           :out std_logic_vector(WIDTH-1 downto 0)
  );
end DE_MAX_SIM;

architecture behavioural of DE_MAX_SIM is                -- cialo architektoniczne projektu
  signal Q1, Q2, Q3, Q  :std_logic_vector(WIDTH-1 downto 0);
  signal T              :std_logic;
begin
  reg1: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, open, C, E, D,  Q1);
  reg2: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, open, C, E, Q1, Q2);
  reg3: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, open, C, E, Q2, Q3);
  
  T <= '1' when (Q2>Q1 and Q2>=Q3 and Q2>Q and E='1') else '0';
  
  regm: entity work.DE_REG_SIM generic map(WIDTH) port map(R, S, L, V, C, T, Q2, Q);
  M <= Q;
end behavioural;                                        -- zakonczenie ciala architektonicznego
                                     -- zakonczenie ciala architektonicznego
