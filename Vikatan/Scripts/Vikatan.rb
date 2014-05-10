# encoding: UTF-8
require 'rubygems'
require 'mechanize'
require 'Fileutils.rb'
require 'logger'

require_relative 'config.rb'


#Main Page  methods
def login ()
	$logger.info("Log in started");

	$mechanizer.get('http://www.vikatan.com/') do |page|
		search_result = page.form_with(:name => 'login') do |login|
		    login.user_id = 'anandanganesan@yahoo.co.in';
		    login.password = 'magicmagic';
  		end.submit
  end

  	$logger.info("Log in completed");
end


#General Vikatan Page Methods
def parsePage ()
	bookClasses = ["anandha-vikatan", "junior-vikatan", "aval-vikatan", "chutti-vikatan", "sakthi-vikatan", "nanayam-vikatan", "motor-vikatan", "pasumai-vikatan"];		

	$logger.info("Parsing main page to get links to books")
	$mechanizer.get('http://www.vikatan.com/')  do |page|
		bookClasses.each do |currentBookClass|

			currentAnchorElement = page.link_with(:class => currentBookClass);

			createCurrentBook(currentBookClass, currentAnchorElement.href);
		end
	end
end


#Method for creating a page for each book. Most important method
def createCurrentBook(bookName, link)
	$logger.info("Getting book:#{bookName} with link #{link}");
	$mechanizer.get(link) do |page|
		
		currentEditionDate = getCurrentEditionDate(page);
		
		$logger.info("Current Edition Date for #{bookName} is #{currentEditionDate}");

		if isCurrentEditionDownloaded("#{$WebHomePath}/#{bookName}/", currentEditionDate) == 0
			$logger.info("Getting Current Edition of #{bookName}")

			createFolderForthisEdition(bookName, currentEditionDate)
			articleLinks 	= generateIndividualPageLinks(page, bookName)	
			pageContent 	= createPageContents (articleLinks)
			outputHTML	 	= createContentPage(pageContent)

			outputFile = File.new("#{$WebHomePath}/#{bookName}/#{currentEditionDate}/#{bookName}-#{currentEditionDate}.html", "w:UTF-8");
			outputFile.puts outputHTML;
				
		else
			
		end

	end
end

def getCurrentEditionDate(page)
	dateSpan = page.parser.css('span#issue_selector');
	return dateSpan.text.chomp.strip.sub(",","");	
end

def isCurrentEditionDownloaded(directoryPath, currentEditionDate)

	$logger.info("Checking if current edition was downloaded...");

	dirContents = Dir.entries(directoryPath)

	if(dirContents.find{|currentItem| currentItem.include? currentEditionDate} == nil)
		$logger.info("Did not find current edition.. ")
		return 0;
	else
		$logger.info("Skipping Current Edition as it has already been downloaded")
		return 1;
	end
end

def createFolderForthisEdition(bookName, currentEditionDate)
	$logger.info("Creating folder #{$WebHomePath}/#{bookName}/#{currentEditionDate}");
		FileUtils.mkdir("#{$WebHomePath}/#{bookName}/#{currentEditionDate}");
	$logger.info("Folder Created");
end

# Get Individual Books
def generateIndividualPageLinks (page, bookName)
		
		$logger.info ("Parsing #{bookName} to get links")

		articleLinks = [];

		articleLists = page.parser.css('ul.MM>li>ul li')
		
		articleLists.each  do |currentArticle|
			anchor = currentArticle.css('a');
			articleLinks << anchor.attribute('href')
		end
		
		$logger.info("#{bookName} is parsed to get links");

		return articleLinks;
end

def createPageContents (articleLinks)
	$logger.info("Creating Page Contents");

	pageContents = "";
	articleLinks.each do |currentArticleLink|	
		$mechanizer.get(currentArticleLink) do |currentArticlePage|
			currentContent 		= currentArticlePage.parser.css('div.art_content');
			currentContent.css("table").remove();
			currentDivString 	= "<div data-role=\'page\' class='AjayPageDiv' style=\"width:94%; margin-left:3%\"> #{currentContent} </div>";
			pageContents 		+= currentDivString;
		end
	end

	$logger.info("Page Contents Completed");

	return pageContents;
end



def createContentPage(content)

	htmlContent = <<END_OF_STRING
	<HTML>
		<Head>
			<meta http-equiv="Content-Type" content="text/html;charset=utf-8" >

			<link rel="stylesheet" href="http://code.jquery.com/mobile/1.4.0/jquery.mobile-1.4.0.min.css" />

			<script src="http://code.jquery.com/jquery-1.9.1.min.js"></script>

			<style>
				.title1 {text-align:center;font-size:40px;color:dimgray;}
				.subtitle1{text-align:center;font-size:25px;color:dimgray;}
				.subtitle2{text-align:center;font-size:15px;color:dimgray;}
				.subtitle3{text-align:center;font-size:15px;color:dimgray;}
				.pageNumber>span{text-align:center;font-size:30px;color:dimgray;}

				.AjayPageDiv {
					display:none;
					margin-bottom:30px;
					font-size:30px;
					color:dimgray;
				}

				.next{
					float:right;
					height:50px;
					width:100px;
				}

				.next>img{
					width:100%;
					height:100%;
				}

				.prev{
					float:left;
					height:50px;
					width:100px;
				}

				.prev>img{
					width:100%;
					height:100%;
				}

				.pageNumber{
					margin-left:40%;
					float:left;
				}


			</style>

			<script type="text/javascript" >
			$( document ).ready(function() {
				$('div.AjayPageDiv').filter(":first").css("display","block");
				
				var pages = $('div.AjayPageDiv');
				var totalPages = pages.length;
				var currentPageNumber = 0;

				$('div.pageNumber>span').text("Page:" + (currentPageNumber+1) + "/" + totalPages );

				$('div.next').click(function(){
					if(currentPageNumber+1 < totalPages)
					{
						$(pages[currentPageNumber]).hide();
						$(pages[currentPageNumber+1]).show();
						currentPageNumber += 1;
						$('div.pageNumber>span').text("Page:" + (currentPageNumber+1) + "/" + totalPages );
					}
				 });

				 $('div.prev').click(function(){
				 	if(currentPageNumber >0)
				 	{
				 		$(pages[currentPageNumber]).hide();
						$(pages[currentPageNumber-1]).show();
						currentPageNumber -= 1;
						$('div.pageNumber>span').text("Page:" + (currentPageNumber+1) + "/" + totalPages );
				 	}
				 });

			});
			</script>

		</Head>
		<Body>
		<div class="header">
		
			<div class="next">
				<img  src="../../next.gif"/>
			</div>

			<div class="prev">
				<img src="../../prev.gif"/>
			</div>
		</div>


			#{content}

		
		<div class="footer">
		
			<div class="next">
				<img  src="../../next.gif"/>
			</div>

			<div class="prev">
				<img src="../../prev.gif"/>
			</div>

			<div class="pageNumber">
				<span></span>
			</div>

		</div>

		</Body>
	</HTMl>
END_OF_STRING

return htmlContent;


end



# Main Method

begin

	$logger = Logger.new("#{$ScriptsHomePath}/logfile.log");
	$logger.level = Logger::INFO;

	$mechanizer = Mechanize.new { |agent|
	  agent.user_agent_alias = 'Mac Safari';
	}

	$logger.info("\n\n**********************************************");
	$logger.info("Program Started");

	login();
	parsePage();

	$logger.info("**********************************************");

rescue => e
	$logger.error(e.message);
	$logger.error(e.backtrace);	
end





#Index Page


