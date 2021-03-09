defmodule Npf.FilingsTest do
  use Npf.DataCase

  alias Npf.Filings

  describe "organizations" do
    alias Npf.Filings.Organization

    @valid_attrs %{
      address_line_1: "some address_line_1",
      address_line_2: "some address_line_2",
      city: "some city",
      ein: 42,
      name: "some name",
      state: "some state",
      zip_code: "some zip_code"
    }
    @update_attrs %{
      address_line_1: "some updated address_line_1",
      address_line_2: "some updated address_line_2",
      city: "some updated city",
      ein: 43,
      name: "some updated name",
      state: "some updated state",
      zip_code: "some updated zip_code"
    }
    @invalid_attrs %{
      address_line_1: nil,
      address_line_2: nil,
      city: nil,
      ein: nil,
      name: nil,
      state: nil,
      zip_code: nil
    }

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Filings.create_organization()

      organization
    end

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Filings.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Filings.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} = Filings.create_organization(@valid_attrs)
      assert organization.address_line_1 == "some address_line_1"
      assert organization.address_line_2 == "some address_line_2"
      assert organization.city == "some city"
      assert organization.ein == 42
      assert organization.name == "some name"
      assert organization.state == "some state"
      assert organization.zip_code == "some zip_code"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Filings.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()

      assert {:ok, %Organization{} = organization} =
               Filings.update_organization(organization, @update_attrs)

      assert organization.address_line_1 == "some updated address_line_1"
      assert organization.address_line_2 == "some updated address_line_2"
      assert organization.city == "some updated city"
      assert organization.ein == 43
      assert organization.name == "some updated name"
      assert organization.state == "some updated state"
      assert organization.zip_code == "some updated zip_code"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Filings.update_organization(organization, @invalid_attrs)

      assert organization == Filings.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Filings.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Filings.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Filings.change_organization(organization)
    end
  end
end
