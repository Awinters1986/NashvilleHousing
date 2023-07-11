/*Data Cleanup using SQL*/

Select *
FROM dbo.Housing

--Standardize Date Format--
Select SaleDate
FROM dbo.Housing

ALTER TABLE Housing
Add SaleDateConverted Date;

Update Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted
FROM dbo.Housing

--Populate Property Address Data--

Select PropertyAddress
FROM dbo.Housing

Select *
FROM dbo.Housing
WHERE PropertyAddress is null

Select *
FROM dbo.Housing
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Housing a
JOIN dbo.Housing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.Housing a
JOIN dbo.Housing b
   on a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

Select *
FROM dbo.Housing
WHERE PropertyAddress is null

--Separating Address into Street Address and City Columns--
Select PropertyAddress
FROM dbo.Housing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as StreetAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM dbo.Housing

ALTER TABLE Housing
Add StreetAddress nvarchar(255);

Update Housing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Housing
Add City nvarchar(255);

Update Housing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--Alternate Way to Separate Street Address, City, State--
Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM dbo.Housing

ALTER TABLE Housing
Add OwnerStreetAddress nvarchar(255);

ALTER TABLE Housing
Add OwnerCity nvarchar(255);

ALTER TABLE Housing
Add OwnerState nvarchar(255);

Update Housing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Update Housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Update Housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Change Y and N to Yes and No in "Sold as Vacant" Field--
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM dbo.Housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' THEN 'YES'
     When SoldAsVacant = 'N' THEN 'NO'
	 ELSE SoldAsVacant
	 END
FROM dbo.Housing

UPDATE Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
						When SoldAsVacant = 'N' THEN 'NO'
						ELSE SoldAsVacant
						END

--Remove Duplicates--
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				    UniqueID
					) row_num
FROM dbo.Housing
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

--Delect Unused Columns--

ALTER TABLE dbo.Housing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate

Select *
FROM dbo.Housing

