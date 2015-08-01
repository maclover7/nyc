Sequel.migration do
  up do
    create_table(:services) do
      primary_key :id
      String :name, :null=>false
    end
  end

  down do
  end
end
