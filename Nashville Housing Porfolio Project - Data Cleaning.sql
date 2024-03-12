-- Cleaning Data Sets in SQL Queries

SELECT *
FROM ProtfolioProject.dbo.NashvilleHousing


--Standardize Date Format

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM ProtfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--If it doesn't update correctly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property address data

SELECT *
FROM ProtfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER By ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProtfolioProject.dbo.NashvilleHousing a
JOIN ProtfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM ProtfolioProject.dbo.NashvilleHousing a
JOIN ProtfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



-- Breaking Out Address Into Individual Columns (Street, City)

--Property Address

SELECT PropertyAddress
FROM ProtfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
--ORDER By ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM ProtfolioProject.dbo.NashvilleHousing

ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE ProtfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) 


ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE ProtfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

SELECT *
FROM ProtfolioProject.dbo.NashvilleHousing



--Owner Address

SELECT OwnerAddress
FROM ProtfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM ProtfolioProject.dbo.NashvilleHousing


ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE ProtfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3) 


ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE ProtfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE ProtfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

SELECT *
FROM ProtfolioProject.dbo.NashvilleHousing



-- Change Y & N To Yes & No In "Sold As Vacant" Field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS NumberSoldAsVacant
FROM ProtfolioProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant
,	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM ProtfolioProject.dbo.NashvilleHousing


UPDATE ProtfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



--Remove Duplicates Using CTE

WITH RowNumCTE As(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	ORDER By UniqueID) AS Row_Num
FROM ProtfolioProject.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1
--Order By PropertyAddress


--Delete Unused Columns

SELECT *
FROM ProtfolioProject.dbo.NashvilleHousing

ALTER TABLE ProtfolioProject.dbo.NashvilleHousing
DROP COLUMN TaxDistrict
